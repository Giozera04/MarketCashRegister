require("dotenv").config();

const { onCall, onRequest, HttpsError } = require("firebase-functions/v2/https");

const admin = require("firebase-admin");
admin.initializeApp();

const { Timestamp } = require("firebase-admin/firestore");

const functions = require("firebase-functions");


const Stripe = require("stripe");
const stripe = new Stripe(process.env.STRIPE_SECRET, {
  apiVersion: "2023-10-16",
});

exports.createPaymentIntent = onCall(async (request) => {
  try {
    const amount = request.data.amount;
    const orderId = request.data.orderId;

    if (typeof amount !== "number" || amount <= 0) {
      throw new HttpsError("invalid-argument", "Invalid amount");
    }

    const db = admin.firestore();

    if (orderId) {
      await db.collection("orders").doc(orderId).set(
        { status: "payment_processing" },
        { merge: true }
      );
    }

    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount),
      currency: "usd",
      automatic_payment_methods: { enabled: true },
      metadata: {
        orderId: orderId || "unknown",
        source: "pos-ios-app",
      },
    });

    return { clientSecret: paymentIntent.client_secret };
  } catch (error) {
    throw new HttpsError("internal", error.message);
  }
});


exports.stripeWebhook = onRequest(
  {
    rawBody: true,
    cors: false,
  },
  async (req, res) => {
    const sig = req.headers["stripe-signature"];
    const endpointSecret =
  process.env.STRIPE_WEBHOOK_SECRET ||
  functions.config().stripe.webhook_secret;


    let event;
    try {
      event = stripe.webhooks.constructEvent(
        req.rawBody,
        sig,
        endpointSecret
      );
    } catch (err) {
      console.error("Webhook signature verification failed:", err.message);
      return res.status(400).send("Webhook Error");
    }

    console.log("🔔 Stripe Event:", event.type);

    const db = admin.firestore();

    try {
      if (event.type === "payment_intent.succeeded") {
        const paymentIntent = event.data.object;
        const orderId = paymentIntent.metadata?.orderId;

        if (!orderId) {
          console.error("Missing orderId in metadata");
          return res.json({ received: true });
        }

        await db.collection("orders").doc(orderId).set(
          {
            status: "paid",
            paymentIntentId: paymentIntent.id,
            paidAt: Timestamp.now(),
          },
          { merge: true }
        );
      }

      if (event.type === "payment_intent.payment_failed") {
        const paymentIntent = event.data.object;
        const orderId = paymentIntent.metadata?.orderId;

        if (!orderId) {
          return res.json({ received: true });
        }

        await db.collection("orders").doc(orderId).set(
          { status: "failed" },
          { merge: true }
        );
      }
    } catch (err) {
      console.error("Firestore update failed:", err);
      return res.status(500).send();
    }

    res.json({ received: true });
  }
);


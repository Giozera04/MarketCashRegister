import SwiftUI
import FirebaseFunctions
import StripePaymentSheet

struct PaymentStripeView: View {
    let orderId: String
    let amount: Int // amount in cents

    @State private var isLoading = false
    @State private var paymentSheet: PaymentSheet?
    @State private var showPaymentSheet = false
    @State private var showReceipt = false
    @State private var errorMessage: String?

    // Firebase Functions
    private let functions: Functions = {
        let f = Functions.functions()

        #if DEBUG
        if ProcessInfo.processInfo.environment["USE_FIREBASE_EMULATOR"] == "1" {
            f.useEmulator(withHost: "192.168.0.19", port: 5001)
            print("🔥 Using Firebase Functions Emulator")
        } else {
            print("🌍 Using Firebase Functions Production")
        }
        #endif

        return f
    }()

    var body: some View {
        VStack(spacing: 24) {
            Text("💳 Payment")
                .font(.largeTitle)
                .bold()

            Text("Secure card payment")
                .foregroundColor(.gray)

            if isLoading {
                ProgressView("Preparing payment...")
            }

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }

            Button(action: startPayment) {
                Text("Pay Now")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(isLoading)
            .padding(.horizontal)

            NavigationLink(
                destination: ReceiptView(orderId: orderId),
                isActive: $showReceipt
            ) {
                EmptyView()
            }
        }
        .padding()
        .navigationTitle("Payment")
        // Make sure we only show the payment sheet when it's loaded
        .paymentSheet(
            isPresented: $showPaymentSheet,
            paymentSheet: paymentSheet ?? PaymentSheet(paymentIntentClientSecret: "", configuration: PaymentSheet.Configuration()),
            onCompletion: handlePaymentResult
        )
    }

    // MARK: - Payment

    func startPayment() {
        isLoading = true
        errorMessage = nil
        
        print("🔹 Starting payment for order:", orderId)
        print("🔹 Amount (cents):", amount)

        let data: [String: Any] = [
            "amount": amount,
            "orderId": orderId
        ]

        functions.httpsCallable("createPaymentIntent").call(data) { result, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    errorMessage = "Function error: \(error.localizedDescription)"
                    print(errorMessage!)
                    return
                }

                guard let dict = result?.data as? [String: Any],
                      let clientSecret = dict["clientSecret"] as? String else {
                    errorMessage = "Invalid response from function"
                    print(errorMessage!)
                    return
                }

                var config = PaymentSheet.Configuration()
                config.merchantDisplayName = "Market Register"
                config.allowsDelayedPaymentMethods = true 

                self.paymentSheet = PaymentSheet(
                    paymentIntentClientSecret: clientSecret,
                    configuration: config
                )

                showPaymentSheet = true
            }
        }
    }

    func handlePaymentResult(result: PaymentSheetResult) {
        switch result {
        case .completed:
            print("✅ Payment successful")
            showReceipt = true

        case .canceled:
            print("⚠️ Payment canceled")

        case .failed(let error):
            errorMessage = "Payment failed: \(error.localizedDescription)"
            print(errorMessage!)
        }
    }
}

import SwiftUI

struct CartViewCheckout: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var locationManager: LocationManager
    
    @State private var navigateToPayment = false
    @State private var lastSavedOrderId: String = ""
    @State private var totalAmountCents: Int = 0 // amount in cents
    
    var safeAreaInsetBottom: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.safeAreaInsets.bottom ?? 10
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 🔝 Top bar
                    TopBar(
                        title: "Cart (\(cartViewModel.totalQuantity))",
                        location: locationManager.currentStore?.name ?? "Your Store",
                        useSafeAreaPadding: false
                    ) {
                        dismiss()
                        NotificationCenter.default.post(name: .returningFromCart, object: nil)
                    }
                    
                    // 🛒 Cart content
                    CartView(
                        cart: cartViewModel.cart,
                        onBack: {
                            dismiss()
                            NotificationCenter.default.post(name: .returningFromCart, object: nil)
                        },
                        storeName: locationManager.currentStore?.name ?? "Your Store"
                    )
                    
                    // 🔽 White bottom section
                    VStack(spacing: 16) {
                        Text("Total: $\(cartViewModel.cart.totalCost(), specifier: "%.2f")")
                            .font(.title2)
                            .bold()
                        
                        Button("✅ Complete Purchase") {
                            let totalCents = Int((cartViewModel.cart.totalCost() * 100).rounded())
                            totalAmountCents = totalCents  // ← assign here
                            print("🛒 Cart total:", cartViewModel.cart.totalCost())
                            print("💰 Total in cents:", totalCents)
                            
                            cartViewModel.checkout { id in
                                if let id = id {
                                    self.lastSavedOrderId = id
                                    print("🆔 Order ID:", id)
                                    print("➡️ Navigating to PaymentStripeView with amount:", totalCents)
                                    self.totalAmountCents = totalCents // <-- update state
                                    navigateToPayment = true
                                } else {
                                    print("❌ Failed to create order")
                                }
                            }
                        }

                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal)
                        
                        Button("Back to Scanner") {
                            dismiss()
                            NotificationCenter.default.post(name: .returningFromCart, object: nil)
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .padding(.horizontal)
                    }
                    .padding(.top, 30)
                    .padding(.horizontal)
                    .padding(.bottom, safeAreaInsetBottom)
                    .background(Color.white)
                    
                    // 🔗 Hidden NavigationLink to Stripe Payment
                    NavigationLink(
                        destination: PaymentStripeView(
                            orderId: lastSavedOrderId,
                            amount: totalAmountCents
                        ),
                        isActive: $navigateToPayment
                    ) {
                        EmptyView()
                    }
                }
            }
        }
    }
}


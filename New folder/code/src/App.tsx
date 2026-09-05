import { useApp, AppProvider } from './context'
import { Splash, SignIn, SignUp, PendingApproval } from './screens/auth'
import { Home } from './screens/home'
import { CategoryProducts, ProductDetail, Search } from './screens/products'
import { Cart, Checkout, UPIPayment, OrderSuccess } from './screens/commerce'
import { MyOrders, OrderDetail, Notifications, Profile } from './screens/account'
import {
  AdminDashboard, AdminOrders, AdminOrderDetail, AdminCatalog,
  AdminRetailers, AdminRetailerDetail, AdminDeliverySettings,
  AdminProductForm, AdminCategoryForm,
} from './screens/admin'

function AppShell() {
  const { screen, navDir } = useApp()
  const animClass = navDir === 'back' ? 'screen-enter-back' : 'screen-enter'

  const screenMap: Record<string, React.ReactNode> = {
    splash: <Splash />,
    signin: <SignIn />,
    signup: <SignUp />,
    pending: <PendingApproval />,
    home: <Home />,
    category: <CategoryProducts />,
    product: <ProductDetail />,
    search: <Search />,
    cart: <Cart />,
    checkout: <Checkout />,
    upi: <UPIPayment />,
    'order-success': <OrderSuccess />,
    'my-orders': <MyOrders />,
    'order-detail': <OrderDetail />,
    notifications: <Notifications />,
    profile: <Profile />,
    'admin-dashboard': <AdminDashboard />,
    'admin-orders': <AdminOrders />,
    'admin-order-detail': <AdminOrderDetail />,
    'admin-catalog': <AdminCatalog />,
    'admin-retailers': <AdminRetailers />,
    'admin-retailer-detail': <AdminRetailerDetail />,
    'admin-delivery': <AdminDeliverySettings />,
    'admin-product-form': <AdminProductForm />,
    'admin-category-form': <AdminCategoryForm />,
  }

  return (
    <div className="flex items-center justify-center min-h-full bg-slate-100 p-0 md:p-6">
      <div
        className="relative w-full max-w-[430px] min-h-screen md:min-h-0 md:h-[844px] bg-slate-50 md:rounded-3xl md:shadow-2xl overflow-hidden flex flex-col"
        style={{ fontFamily: "'Inter', system-ui, sans-serif" }}
      >
        <div key={screen} className={`${animClass} flex-1 flex flex-col min-h-0 h-full`}>
          {screenMap[screen] ?? <div className="flex-1 flex items-center justify-center text-slate-400">Screen not found</div>}
        </div>
      </div>
    </div>
  )
}

export default function App() {
  return (
    <AppProvider>
      <AppShell />
    </AppProvider>
  )
}

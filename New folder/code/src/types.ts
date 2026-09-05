export type Screen =
  | 'splash' | 'signin' | 'signup' | 'pending'
  | 'home' | 'category' | 'product' | 'search'
  | 'cart' | 'checkout' | 'upi' | 'order-success'
  | 'my-orders' | 'order-detail' | 'notifications' | 'profile'
  | 'admin-dashboard' | 'admin-orders' | 'admin-order-detail'
  | 'admin-catalog' | 'admin-retailers' | 'admin-retailer-detail'
  | 'admin-delivery' | 'admin-product-form' | 'admin-category-form'

export interface Category {
  id: string
  name: string
  emoji: string
  bgColor: string
  active: boolean
}

export interface PriceTier {
  label: string
  price: number
}

export interface Product {
  id: string
  name: string
  categoryId: string
  unit: string
  price: number
  priceTiers: PriceTier[]
  stock: number
  emoji: string
  description: string
  active: boolean
}

export interface OrderItem {
  productId: string
  name: string
  qty: number
  unit: string
  unitPrice: number
  total: number
}

export interface Order {
  id: string
  retailerId: string
  retailerName: string
  items: OrderItem[]
  subtotal: number
  deliveryCharge: number
  total: number
  status: 'pending' | 'confirmed' | 'out-for-delivery' | 'delivered' | 'cancelled'
  date: string
  address: string
  payment: string
  paid: boolean
}

export interface Retailer {
  id: string
  name: string
  owner: string
  phone: string
  email: string
  address: string
  city: string
  pincode: string
  gst: string
  hours: string
  accountHolder: string
  accountNo: string
  ifsc: string
  bankName: string
  registeredOn: string
  status: 'approved' | 'pending'
  totalSpend: number
  orderCount: number
}

export interface CartItem {
  productId: string
  qty: number
}

export interface AppNotification {
  id: string
  title: string
  body: string
  time: string
  read: boolean
}

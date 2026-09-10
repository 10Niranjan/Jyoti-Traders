import { createContext, useContext, useState, useCallback, ReactNode } from 'react'
import type { Screen, CartItem, Order, Retailer, AppNotification } from './types'
import {
  retailers as initialRetailers,
  orders as initialOrders,
  notifications as initialNotifications,
} from './data'

interface NavEntry { screen: Screen; params: Record<string, unknown> }

interface AppContextType {
  screen: Screen
  params: Record<string, unknown>
  navDir: 'forward' | 'back'
  navigate: (s: Screen, p?: Record<string, unknown>) => void
  back: () => void
  cart: CartItem[]
  addToCart: (productId: string, qty: number) => void
  removeFromCart: (productId: string) => void
  updateQty: (productId: string, qty: number) => void
  clearCart: () => void
  cartCount: number
  isAdmin: boolean
  setIsAdmin: (v: boolean) => void
  notifications: AppNotification[]
  unreadCount: number
  markAllRead: () => void
  lastOrderId: string
  setLastOrderId: (id: string) => void
  retailers: Retailer[]
  approveRetailer: (id: string) => void
  rejectRetailer: (id: string) => void
  orders: Order[]
  updateOrderStatus: (id: string, status: Order['status']) => void
  markOrderPaid: (id: string) => void
  placeOrder: (order: Order) => void
}

export const AppContext = createContext<AppContextType>(null!)
export const useApp = () => useContext(AppContext)

export function AppProvider({ children }: { children: ReactNode }) {
  const [screen, setScreen] = useState<Screen>('splash')
  const [params, setParams] = useState<Record<string, unknown>>({})
  const [navDir, setNavDir] = useState<'forward' | 'back'>('forward')
  const [history, setHistory] = useState<NavEntry[]>([])
  const [cart, setCart] = useState<CartItem[]>([])
  const [isAdmin, setIsAdmin] = useState(false)
  const [notifications, setNotifications] = useState<AppNotification[]>(initialNotifications)
  const [lastOrderId, setLastOrderId] = useState('')
  const [retailers, setRetailers] = useState<Retailer[]>(initialRetailers)
  const [orders, setOrders] = useState<Order[]>(initialOrders)

  const navigate = useCallback((s: Screen, p: Record<string, unknown> = {}) => {
    setNavDir('forward')
    setHistory(h => [...h, { screen, params }])
    setScreen(s)
    setParams(p)
  }, [screen, params])

  const back = useCallback(() => {
    const prev = history[history.length - 1]
    if (!prev) return
    setNavDir('back')
    setHistory(h => h.slice(0, -1))
    setScreen(prev.screen)
    setParams(prev.params)
  }, [history])

  const addToCart = useCallback((productId: string, qty: number) => {
    setCart(c => {
      const existing = c.find(i => i.productId === productId)
      if (existing) return c.map(i => i.productId === productId ? { ...i, qty: i.qty + qty } : i)
      return [...c, { productId, qty }]
    })
  }, [])

  const removeFromCart = useCallback((productId: string) => {
    setCart(c => c.filter(i => i.productId !== productId))
  }, [])

  const updateQty = useCallback((productId: string, qty: number) => {
    if (qty <= 0) { removeFromCart(productId); return }
    setCart(c => c.map(i => i.productId === productId ? { ...i, qty } : i))
  }, [removeFromCart])

  const clearCart = useCallback(() => setCart([]), [])
  const cartCount = cart.reduce((s, i) => s + i.qty, 0)
  const unreadCount = notifications.filter(n => !n.read).length
  const markAllRead = () => setNotifications(ns => ns.map(n => ({ ...n, read: true })))

  const approveRetailer = (id: string) =>
    setRetailers(rs => rs.map(r => r.id === id ? { ...r, status: 'approved' as const } : r))
  const rejectRetailer = (id: string) =>
    setRetailers(rs => rs.filter(r => r.id !== id))

  const updateOrderStatus = (id: string, status: Order['status']) =>
    setOrders(os => os.map(o => o.id === id ? { ...o, status } : o))
  const markOrderPaid = (id: string) =>
    setOrders(os => os.map(o => o.id === id ? { ...o, paid: true } : o))
  const placeOrder = (order: Order) =>
    setOrders(os => [order, ...os])

  return (
    <AppContext.Provider value={{
      screen, params, navDir, navigate, back,
      cart, addToCart, removeFromCart, updateQty, clearCart, cartCount,
      isAdmin, setIsAdmin,
      notifications, unreadCount, markAllRead,
      lastOrderId, setLastOrderId,
      retailers, approveRetailer, rejectRetailer,
      orders, updateOrderStatus, markOrderPaid, placeOrder,
    }}>
      {children}
    </AppContext.Provider>
  )
}

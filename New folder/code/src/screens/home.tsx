import { useApp } from '../context'
import { products, categories, CURRENT_RETAILER, orders } from '../data'
import { CartBar, Avatar } from '../components'
import type { Product } from '../types'

// ─── Home ─────────────────────────────────────────────────────────────────────

export function Home() {
  const { navigate, cart, addToCart, updateQty, removeFromCart, unreadCount } = useApp()

  // Cart total
  const cartTotal = cart.reduce((sum, ci) => {
    const p = products.find(p => p.id === ci.productId)
    return sum + (p ? p.price * ci.qty : 0)
  }, 0)

  // Previously ordered products (buy again)
  const retailerOrders = orders.filter(o => o.retailerId === CURRENT_RETAILER && o.status !== 'cancelled')
  const prevProductIds = [...new Set(retailerOrders.flatMap(o => o.items.map(i => i.productId)))]
  const buyAgainProducts = prevProductIds.map(id => products.find(p => p.id === id)).filter(Boolean) as Product[]

  // Low stock check
  const lowStockItems = buyAgainProducts.filter(p => p.stock <= 10)

  const getCartQty = (id: string) => cart.find(c => c.productId === id)?.qty ?? 0

  return (
    <div className="flex-1 flex flex-col min-h-0 bg-slate-50">
      {/* Header */}
      <div className="bg-white px-4 pt-4 pb-3 flex items-start justify-between border-b border-slate-100">
        <div>
          <h1 className="text-lg font-bold text-slate-900">Sharma General Store</h1>
          <p className="text-xs text-slate-400 font-medium">Owner: Ramesh Sharma</p>
        </div>
        <div className="flex items-center gap-3">
          <button onClick={() => navigate('notifications')} className="relative">
            <span className="text-xl">🔔</span>
            {unreadCount > 0 && (
              <span className="absolute -top-1 -right-1 w-4 h-4 bg-red-500 rounded-full text-white text-[9px] font-bold flex items-center justify-center">{unreadCount}</span>
            )}
          </button>
          <button onClick={() => navigate('signin')} className="text-xl">↗</button>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto no-scrollbar pb-32">
        {/* Delivery Banner */}
        <div className="mx-4 mt-4 bg-violet-600 rounded-2xl p-4 flex items-center gap-3">
          <span className="text-2xl">🚚</span>
          <div>
            <p className="text-white font-semibold text-sm">Own Fleet Delivery</p>
            <p className="text-violet-200 text-xs">Fast, reliable delivery on every order</p>
          </div>
        </div>

        {/* Low stock alert */}
        {lowStockItems.length > 0 && (
          <div className="mx-4 mt-3 bg-red-50 border border-red-200 rounded-xl px-3.5 py-2.5 flex items-center gap-2">
            <span className="text-sm">⚠️</span>
            <p className="text-xs text-red-700 font-medium">
              {lowStockItems.length} of your regulars are low or out of stock.
            </p>
          </div>
        )}

        {/* Buy Again */}
        {buyAgainProducts.length > 0 && (
          <div className="mt-5 px-4">
            <h2 className="text-base font-bold text-slate-900 mb-3">Buy Again</h2>
            <div className="flex gap-3 overflow-x-auto no-scrollbar pb-1">
              {buyAgainProducts.map(p => {
                const qty = getCartQty(p.id)
                return (
                  <div key={p.id} className="w-40 flex-shrink-0 bg-white rounded-2xl overflow-hidden shadow-sm border border-slate-100">
                    <div
                      className="h-24 flex items-center justify-center text-4xl cursor-pointer"
                      style={{ backgroundColor: categories.find(c => c.id === p.categoryId)?.bgColor + '18' }}
                      onClick={() => navigate('product', { productId: p.id })}
                    >
                      {p.emoji}
                    </div>
                    <div className="p-2.5">
                      <p className="text-xs font-semibold text-slate-800 leading-tight line-clamp-2">{p.name}</p>
                      <p className="text-[11px] text-slate-400 mt-0.5">from ₹{p.price}/{p.unit}</p>
                      <p className="text-sm font-bold text-slate-900 mt-0.5">₹{(p.price * Math.max(qty || 1, 1)).toLocaleString('en-IN')}</p>
                      {qty === 0 ? (
                        <button
                          onClick={() => addToCart(p.id, 1)}
                          className="mt-2 w-full bg-violet-50 text-violet-600 text-xs font-bold py-1.5 rounded-lg hover:bg-violet-100 transition-colors border border-violet-200"
                        >
                          ADD
                        </button>
                      ) : (
                        <div className="mt-2 flex items-center justify-between bg-violet-600 rounded-lg px-2 py-1">
                          <button onClick={() => { if (qty === 1) removeFromCart(p.id); else updateQty(p.id, qty - 1) }} className="text-white font-bold text-sm">−</button>
                          <span className="text-white text-xs font-bold">{qty}</span>
                          <button onClick={() => addToCart(p.id, 1)} className="text-white font-bold text-sm">+</button>
                        </div>
                      )}
                    </div>
                  </div>
                )
              })}
            </div>
          </div>
        )}

        {/* Browse Categories */}
        <div className="mt-5 px-4">
          <h2 className="text-base font-bold text-slate-900 mb-3">Browse Categories</h2>
          <div className="grid grid-cols-4 gap-3">
            {categories.map(cat => (
              <button
                key={cat.id}
                onClick={() => navigate('category', { categoryId: cat.id })}
                className="flex flex-col items-center gap-1.5 group"
              >
                <div
                  className="w-14 h-14 rounded-full flex items-center justify-center text-2xl shadow-sm group-active:scale-95 transition-transform"
                  style={{ backgroundColor: cat.bgColor }}
                >
                  {cat.emoji}
                </div>
                <span className="text-[10px] font-medium text-slate-600 text-center leading-tight">{cat.name}</span>
              </button>
            ))}
          </div>
        </div>

        {/* Featured Products */}
        <div className="mt-5 px-4">
          <h2 className="text-base font-bold text-slate-900 mb-3">Today's Picks</h2>
          <div className="space-y-2">
            {products.slice(0, 4).map(p => {
              const qty = getCartQty(p.id)
              const cat = categories.find(c => c.id === p.categoryId)
              return (
                <div key={p.id} className="bg-white rounded-2xl p-3.5 flex items-center gap-3 border border-slate-100 shadow-sm">
                  <div
                    className="w-14 h-14 rounded-xl flex items-center justify-center text-2xl flex-shrink-0"
                    style={{ backgroundColor: (cat?.bgColor ?? '#7C3AED') + '18' }}
                  >
                    {p.emoji}
                  </div>
                  <div className="flex-1 min-w-0" onClick={() => navigate('product', { productId: p.id })}>
                    <p className="text-sm font-semibold text-slate-800 truncate">{p.name}</p>
                    <p className="text-[11px] text-slate-400">from ₹{p.price}/{p.unit}</p>
                    {p.stock <= 10 && <p className="text-[10px] text-red-500 font-medium">▲ Low stock: {p.stock}</p>}
                  </div>
                  {qty === 0 ? (
                    <button
                      onClick={() => addToCart(p.id, 1)}
                      className="bg-violet-50 text-violet-600 text-xs font-bold px-3 py-1.5 rounded-lg hover:bg-violet-100 transition-colors border border-violet-200 flex-shrink-0"
                    >
                      ADD
                    </button>
                  ) : (
                    <div className="flex items-center gap-1 bg-violet-600 rounded-lg px-2 py-1 flex-shrink-0">
                      <button onClick={() => { if (qty === 1) removeFromCart(p.id); else updateQty(p.id, qty - 1) }} className="text-white font-bold w-5 text-center">−</button>
                      <span className="text-white text-xs font-bold w-4 text-center">{qty}</span>
                      <button onClick={() => addToCart(p.id, 1)} className="text-white font-bold w-5 text-center">+</button>
                    </div>
                  )}
                </div>
              )
            })}
          </div>
        </div>
      </div>

      {/* Bottom nav */}
      <BottomTabBar />
      {cart.length > 0 && <CartBar total={cartTotal} />}
    </div>
  )
}

// ─── Bottom Tab Bar (inline for Home) ────────────────────────────────────────

function BottomTabBar() {
  const { screen, navigate, unreadCount } = useApp()
  const tabs = [
    { id: 'home', label: 'Home', icon: '🏠' },
    { id: 'search', label: 'Search', icon: '🔍' },
    { id: 'my-orders', label: 'Orders', icon: '📋' },
    { id: 'profile', label: 'Profile', icon: '👤' },
  ]
  return (
    <div className="absolute bottom-0 left-0 right-0 bg-white border-t border-slate-100 z-30">
      <div className="flex">
        {tabs.map(tab => (
          <button
            key={tab.id}
            onClick={() => navigate(tab.id as any)}
            className={`flex-1 flex flex-col items-center gap-0.5 py-2.5 ${screen === tab.id ? 'text-violet-600' : 'text-slate-400'}`}
          >
            <span className="text-xl leading-none relative">
              {tab.icon}
              {tab.id === 'my-orders' && unreadCount > 0 && (
                <span className="absolute -top-1 -right-1 w-2 h-2 bg-red-500 rounded-full" />
              )}
            </span>
            <span className={`text-[10px] font-medium ${screen === tab.id ? 'text-violet-600' : 'text-slate-400'}`}>{tab.label}</span>
          </button>
        ))}
      </div>
    </div>
  )
}

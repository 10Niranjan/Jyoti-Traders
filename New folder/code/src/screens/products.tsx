import { useState } from 'react'
import { useApp } from '../context'
import { products, categories } from '../data'
import { BackButton, CartBar } from '../components'
import type { Product } from '../types'

// ─── Category Products ────────────────────────────────────────────────────────

export function CategoryProducts() {
  const { params, navigate, cart, addToCart, updateQty, removeFromCart } = useApp()
  const categoryId = params.categoryId as string
  const category = categories.find(c => c.id === categoryId)
  const catProducts = products.filter(p => p.categoryId === categoryId && p.active)

  const cartTotal = cart.reduce((sum, ci) => {
    const p = products.find(p => p.id === ci.productId)
    return sum + (p ? p.price * ci.qty : 0)
  }, 0)

  const getQty = (id: string) => cart.find(c => c.productId === id)?.qty ?? 0

  return (
    <div className="flex-1 flex flex-col min-h-0 bg-slate-50">
      <div className="bg-white px-4 pt-4 pb-3 flex items-center gap-3 border-b border-slate-100">
        <BackButton />
        <h1 className="text-lg font-bold text-slate-900">{category?.name ?? 'Products'}</h1>
      </div>

      <div className="flex-1 overflow-y-auto no-scrollbar pb-32">
        <div className="grid grid-cols-2 gap-3 p-4">
          {catProducts.map(p => {
            const qty = getQty(p.id)
            return (
              <ProductCard
                key={p.id}
                product={p}
                qty={qty}
                bgColor={category?.bgColor ?? '#7C3AED'}
                onView={() => navigate('product', { productId: p.id })}
                onAdd={() => addToCart(p.id, 1)}
                onInc={() => addToCart(p.id, 1)}
                onDec={() => { if (qty === 1) removeFromCart(p.id); else updateQty(p.id, qty - 1) }}
              />
            )
          })}
        </div>
      </div>

      {cart.length > 0 && <CartBar total={cartTotal} />}
    </div>
  )
}

function ProductCard({
  product, qty, bgColor, onView, onAdd, onInc, onDec,
}: {
  product: Product; qty: number; bgColor: string
  onView: () => void; onAdd: () => void; onInc: () => void; onDec: () => void
}) {
  return (
    <div className="bg-white rounded-2xl overflow-hidden shadow-sm border border-slate-100">
      <div
        className="h-36 flex items-center justify-center text-5xl cursor-pointer active:opacity-90"
        style={{ backgroundColor: bgColor + '18' }}
        onClick={onView}
      >
        {product.emoji}
      </div>
      <div className="p-3">
        <p className="text-sm font-semibold text-slate-800 leading-snug line-clamp-2 cursor-pointer" onClick={onView}>
          {product.name}
        </p>
        <p className="text-[11px] text-slate-400 mt-0.5">per {product.unit}</p>
        <p className="text-base font-bold text-violet-600 mt-0.5">₹{product.price.toLocaleString('en-IN')}</p>
        {product.stock <= 10 && (
          <p className="text-[10px] text-red-500 font-medium">Low stock: {product.stock}</p>
        )}
        <div className="mt-2">
          {qty === 0 ? (
            <button
              onClick={onAdd}
              className="w-full border border-violet-600 text-violet-600 text-sm font-bold py-1.5 rounded-xl hover:bg-violet-50 transition-colors"
            >
              ADD
            </button>
          ) : (
            <div className="flex items-center justify-between bg-violet-600 rounded-xl px-2.5 py-1.5">
              <button onClick={onDec} className="text-white font-bold text-base w-6 text-center">−</button>
              <span className="text-white text-sm font-bold">{qty}</span>
              <button onClick={onInc} className="text-white font-bold text-base w-6 text-center">+</button>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

// ─── Product Detail ───────────────────────────────────────────────────────────

export function ProductDetail() {
  const { params, navigate, cart, addToCart, updateQty, removeFromCart } = useApp()
  const productId = params.productId as string
  const product = products.find(p => p.id === productId)!
  const category = categories.find(c => c.id === product?.categoryId)
  const [qty, setQty] = useState(1)
  const [toast, setToast] = useState(false)

  const cartQty = cart.find(c => c.productId === productId)?.qty ?? 0
  const cartTotal = cart.reduce((sum, ci) => {
    const p = products.find(p => p.id === ci.productId)
    return sum + (p ? p.price * ci.qty : 0)
  }, 0)

  const presets = [1, 2, 5]
  const total = product ? product.price * qty : 0

  const handleAdd = () => {
    addToCart(product.id, qty)
    setToast(true)
    setTimeout(() => setToast(false), 2500)
  }

  if (!product) return null

  return (
    <div className="flex-1 flex flex-col min-h-0 bg-white">
      <div className="px-4 pt-4 pb-3 flex items-center gap-3 border-b border-slate-100">
        <BackButton />
        <h1 className="text-base font-bold text-slate-900">Product Details</h1>
      </div>

      <div className="flex-1 overflow-y-auto no-scrollbar pb-28">
        {/* Product image */}
        <div className="h-56 flex items-center justify-center text-8xl" style={{ backgroundColor: (category?.bgColor ?? '#7C3AED') + '14' }}>
          {product.emoji}
        </div>

        <div className="p-5 space-y-5">
          {/* Name + stock */}
          <div>
            <h2 className="text-xl font-bold text-slate-900">{product.name}</h2>
            <p className="text-sm text-slate-400 mt-0.5">Sold per {product.unit}</p>
            <p className="text-3xl font-extrabold text-violet-600 mt-2">₹{product.price.toLocaleString('en-IN')}</p>
            <p className="text-sm font-medium text-emerald-600 mt-1">{product.stock} {product.unit}s in stock</p>
          </div>

          {/* Price tiers */}
          {product.priceTiers.length > 1 && (
            <div className="bg-violet-50 rounded-2xl p-4">
              <p className="text-sm font-semibold text-slate-700 mb-2">Rate by quantity (₹ per {product.unit})</p>
              <p className="text-xs text-slate-400 mb-3">The whole weight is billed at the rate its band earns.</p>
              <div className="grid grid-cols-2 gap-2">
                {product.priceTiers.map((tier, i) => (
                  <div key={i} className="bg-white rounded-xl p-2.5 border border-slate-100">
                    <p className="text-[10px] text-slate-400">{tier.label}</p>
                    <p className="text-sm font-bold text-slate-900">₹{tier.price} /{product.unit}</p>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Quantity */}
          <div>
            <p className="text-sm font-semibold text-slate-900 mb-2">Quantity</p>
            <div className="flex items-center gap-2 mb-3">
              {presets.map(p => (
                <button
                  key={p}
                  onClick={() => setQty(p)}
                  className={`px-3.5 py-1.5 rounded-full text-sm font-medium border transition-colors ${qty === p ? 'bg-violet-600 text-white border-violet-600' : 'border-slate-200 text-slate-600 hover:border-violet-400'}`}
                >
                  {p} {product.unit === 'tin' ? 'tin' : product.unit === 'can' ? 'can' : product.unit === 'pouch' ? 'pouch' : product.unit}
                  {p > 1 ? 's' : ''}
                </button>
              ))}
            </div>
            <div className="flex items-center justify-between">
              <p className="text-2xl font-bold text-slate-900">₹{total.toLocaleString('en-IN')}</p>
              <div className="flex items-center gap-3 bg-slate-100 rounded-xl px-2 py-1">
                <button onClick={() => setQty(q => Math.max(1, q - 1))} className="w-8 h-8 flex items-center justify-center text-slate-700 font-bold text-xl hover:bg-slate-200 rounded-lg transition-colors">−</button>
                <span className="text-slate-900 font-bold w-6 text-center">{qty}</span>
                <button onClick={() => setQty(q => q + 1)} className="w-8 h-8 flex items-center justify-center text-slate-700 font-bold text-xl hover:bg-slate-200 rounded-lg transition-colors">+</button>
              </div>
            </div>
          </div>

          {/* Description */}
          <div>
            <p className="text-sm font-semibold text-slate-900 mb-1">Description</p>
            <p className="text-sm text-slate-500 leading-relaxed">{product.description}</p>
          </div>

          {/* Toast */}
          {toast && (
            <div className="slide-up flex items-center justify-between bg-slate-900 text-white rounded-2xl px-4 py-3 shadow-lg">
              <span className="text-sm font-medium">✓ {product.name.split(' ').slice(0, 2).join(' ')} added to cart</span>
              <button onClick={() => navigate('cart')} className="text-violet-300 text-sm font-bold ml-4">VIEW CART</button>
            </div>
          )}
        </div>
      </div>

      {/* CTA */}
      <div className="px-4 pb-4 pt-2 bg-white border-t border-slate-100">
        <button
          onClick={handleAdd}
          className="w-full bg-violet-600 hover:bg-violet-700 text-white font-bold py-4 rounded-2xl transition-colors text-base"
        >
          Add {qty} {qty > 1 ? product.unit + 's' : product.unit} · ₹{total.toLocaleString('en-IN')}
        </button>
      </div>

      {cart.length > 0 && <CartBar total={cartTotal} />}
    </div>
  )
}

// ─── Search ───────────────────────────────────────────────────────────────────

export function Search() {
  const { navigate, cart, addToCart, updateQty, removeFromCart } = useApp()
  const [query, setQuery] = useState('')
  const [recent, setRecent] = useState(['rice', 'oil', 'sugar', 'wheat flour', 'salt'])

  const cartTotal = cart.reduce((sum, ci) => {
    const p = products.find(p => p.id === ci.productId)
    return sum + (p ? p.price * ci.qty : 0)
  }, 0)

  const results = query.trim()
    ? products.filter(p => p.name.toLowerCase().includes(query.toLowerCase()) || p.description.toLowerCase().includes(query.toLowerCase()))
    : []

  const handleSearch = (term: string) => {
    setQuery(term)
    if (term && !recent.includes(term)) setRecent(r => [term, ...r].slice(0, 8))
  }

  const getQty = (id: string) => cart.find(c => c.productId === id)?.qty ?? 0

  return (
    <div className="flex-1 flex flex-col min-h-0 bg-slate-50">
      {/* Search bar */}
      <div className="bg-white px-4 pt-4 pb-3 border-b border-slate-100">
        <div className="flex items-center gap-2 bg-slate-50 rounded-xl px-3.5 py-2.5 border border-slate-200 focus-within:border-violet-400 focus-within:ring-2 focus-within:ring-violet-100 transition-all">
          <span className="text-slate-400">🔍</span>
          <input
            autoFocus
            type="text"
            value={query}
            onChange={e => setQuery(e.target.value)}
            onKeyDown={e => e.key === 'Enter' && handleSearch(query)}
            placeholder="Search products..."
            className="flex-1 bg-transparent text-sm text-slate-900 placeholder-slate-400"
          />
          {query && (
            <button onClick={() => setQuery('')} className="text-slate-400 text-lg leading-none">×</button>
          )}
        </div>
      </div>

      <div className="flex-1 overflow-y-auto no-scrollbar pb-24">
        {/* Recent searches */}
        {!query && (
          <div className="px-4 pt-4">
            <div className="flex items-center justify-between mb-3">
              <p className="text-sm font-semibold text-slate-700">Recent Searches</p>
              <button onClick={() => setRecent([])} className="text-xs text-violet-600 font-medium">Clear</button>
            </div>
            <div className="flex flex-wrap gap-2">
              {recent.map(term => (
                <button
                  key={term}
                  onClick={() => setQuery(term)}
                  className="bg-white border border-slate-200 rounded-full px-3 py-1.5 text-sm text-slate-600 hover:border-violet-400 hover:text-violet-600 transition-colors shadow-sm"
                >
                  {term}
                </button>
              ))}
            </div>
          </div>
        )}

        {/* Results */}
        {query && results.length === 0 && (
          <div className="flex flex-col items-center justify-center py-16 gap-3">
            <span className="text-4xl">🔍</span>
            <p className="text-slate-400 text-sm">No products found for "{query}"</p>
          </div>
        )}

        {results.length > 0 && (
          <div className="px-4 pt-4 space-y-2">
            <p className="text-xs text-slate-400 font-medium mb-2">{results.length} result{results.length > 1 ? 's' : ''}</p>
            {results.map(p => {
              const qty = getQty(p.id)
              const cat = categories.find(c => c.id === p.categoryId)
              return (
                <div key={p.id} className="bg-white rounded-2xl p-3.5 flex items-center gap-3 border border-slate-100 shadow-sm">
                  <div
                    className="w-14 h-14 rounded-xl flex items-center justify-center text-2xl flex-shrink-0 cursor-pointer"
                    style={{ backgroundColor: (cat?.bgColor ?? '#7C3AED') + '18' }}
                    onClick={() => navigate('product', { productId: p.id })}
                  >
                    {p.emoji}
                  </div>
                  <div className="flex-1 min-w-0 cursor-pointer" onClick={() => navigate('product', { productId: p.id })}>
                    <p className="text-sm font-semibold text-slate-800 truncate">{p.name}</p>
                    <p className="text-xs text-violet-600 font-bold">₹{p.price}/{p.unit}</p>
                    {p.stock <= 10 && <p className="text-[10px] text-red-500">Low stock: {p.stock}</p>}
                  </div>
                  {qty === 0 ? (
                    <button onClick={() => addToCart(p.id, 1)} className="bg-violet-50 text-violet-600 text-xs font-bold px-3 py-1.5 rounded-lg border border-violet-200">ADD</button>
                  ) : (
                    <div className="flex items-center gap-1 bg-violet-600 rounded-lg px-2 py-1.5">
                      <button onClick={() => { if (qty === 1) removeFromCart(p.id); else updateQty(p.id, qty - 1) }} className="text-white font-bold">−</button>
                      <span className="text-white text-xs font-bold w-4 text-center">{qty}</span>
                      <button onClick={() => addToCart(p.id, 1)} className="text-white font-bold">+</button>
                    </div>
                  )}
                </div>
              )
            })}
          </div>
        )}
      </div>

      {/* Bottom nav */}
      <SearchBottomNav />
      {cart.length > 0 && <CartBar total={cartTotal} />}
    </div>
  )
}

function SearchBottomNav() {
  const { navigate, screen, unreadCount } = useApp()
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
          <button key={tab.id} onClick={() => navigate(tab.id as any)} className={`flex-1 flex flex-col items-center gap-0.5 py-2.5 ${screen === tab.id ? 'text-violet-600' : 'text-slate-400'}`}>
            <span className="text-xl leading-none relative">
              {tab.icon}
              {tab.id === 'my-orders' && unreadCount > 0 && <span className="absolute -top-1 -right-1 w-2 h-2 bg-red-500 rounded-full" />}
            </span>
            <span className={`text-[10px] font-medium ${screen === tab.id ? 'text-violet-600' : 'text-slate-400'}`}>{tab.label}</span>
          </button>
        ))}
      </div>
    </div>
  )
}

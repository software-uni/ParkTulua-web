import './App.css'

function App() {
  return (
    <main className="min-h-screen bg-neutro-100 font-sans p-8">
      <div className="max-w-5xl mx-auto space-y-8">

        <header>
          <h1 className="text-3xl font-bold text-neutro-900">
            Prueba del Theme Global
          </h1>
          <p className="text-neutro-600 mt-2">
            Verificando que los tokens de <code>index.css</code> generan utilidades.
          </p>
        </header>

        {/* Colores de Marca */}
        <section>
          <h2 className="text-xl font-semibold text-neutro-900 mb-3">
            Colores de Marca
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="bg-marca-primario text-white p-6 rounded-card shadow-card">
              <p className="font-semibold">marca-primario</p>
              <p className="text-sm opacity-90">#6b5aed</p>
            </div>
            <div className="bg-marca-oscuro text-white p-6 rounded-card shadow-card">
              <p className="font-semibold">marca-oscuro</p>
              <p className="text-sm opacity-90">#4c3bca</p>
            </div>
            <div className="bg-marca-claro text-marca-oscuro p-6 rounded-card shadow-card">
              <p className="font-semibold">marca-claro</p>
              <p className="text-sm opacity-80">#ebe8ff</p>
            </div>
          </div>
        </section>

        {/* Estados */}
        <section>
          <h2 className="text-xl font-semibold text-neutro-900 mb-3">
            Estados de Disponibilidad
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="bg-estado-disponible-bg border border-estado-disponible rounded-card p-6 shadow-card">
              <span className="inline-block bg-estado-disponible text-white text-xs font-semibold px-3 py-1 rounded-chip">
                Disponible
              </span>
              <p className="mt-3 text-estado-disponible-texto font-medium">
                12 cupos libres
              </p>
            </div>

            <div className="bg-estado-poca-bg border border-estado-poca rounded-card p-6 shadow-card">
              <span className="inline-block bg-estado-poca text-white text-xs font-semibold px-3 py-1 rounded-chip">
                Poca disponibilidad
              </span>
              <p className="mt-3 text-estado-poca-texto font-medium">
                Solo 3 cupos
              </p>
            </div>

            <div className="bg-estado-lleno-bg border border-estado-lleno rounded-card p-6 shadow-card">
              <span className="inline-block bg-estado-lleno text-white text-xs font-semibold px-3 py-1 rounded-chip">
                Lleno
              </span>
              <p className="mt-3 text-estado-lleno-texto font-medium">
                Sin cupos
              </p>
            </div>
          </div>
        </section>

        {/* Neutros */}
        <section>
          <h2 className="text-xl font-semibold text-neutro-900 mb-3">
            Colores Neutros
          </h2>
          <div className="grid grid-cols-2 md:grid-cols-5 gap-3">
            <div className="bg-neutro-900 text-white p-4 rounded-card text-center text-sm">
              neutro-900
            </div>
            <div className="bg-neutro-600 text-white p-4 rounded-card text-center text-sm">
              neutro-600
            </div>
            <div className="bg-neutro-300 text-neutro-900 p-4 rounded-card text-center text-sm">
              neutro-300
            </div>
            <div className="bg-neutro-100 text-neutro-900 p-4 rounded-card text-center text-sm border border-neutro-300">
              neutro-100
            </div>
            <div className="bg-neutro-0 text-neutro-900 p-4 rounded-card text-center text-sm border border-neutro-300">
              neutro-0
            </div>
          </div>
        </section>

        {/* Radios */}
        <section>
          <h2 className="text-xl font-semibold text-neutro-900 mb-3">
            Border Radius
          </h2>
          <div className="flex flex-wrap gap-4 items-center">
            <div className="rounded-btn bg-marca-primario text-white px-5 py-3">
              rounded-btn (8px)
            </div>
            <div className="rounded-card bg-marca-primario text-white px-5 py-3">
              rounded-card (12px)
            </div>
            <div className="rounded-modal bg-marca-primario text-white px-5 py-3">
              rounded-modal (16px)
            </div>
            <div className="rounded-chip bg-marca-primario text-white px-5 py-3">
              rounded-chip (999px)
            </div>
          </div>
        </section>

        {/* Sombras */}
        <section>
          <h2 className="text-xl font-semibold text-neutro-900 mb-3">
            Sombras
          </h2>
          <div className="flex flex-wrap gap-6">
            <div className="bg-neutro-0 shadow-card rounded-card p-6 w-56">
              shadow-card
            </div>
          </div>
        </section>

        {/* Tipografía */}
        <section>
          <h2 className="text-xl font-semibold text-neutro-900 mb-3">
            Tipografía
          </h2>
          <div className="bg-neutro-0 rounded-card shadow-card p-6">
            <p className="font-sans text-neutro-900 text-2xl">
              font-sans → Inter
            </p>
            <p className="font-sans text-neutro-600 mt-1 text-sm">
              Si la fuente se ve como Inter, el token está aplicado.
            </p>
          </div>
        </section>

      </div>
    </main>
  )
}

export default App

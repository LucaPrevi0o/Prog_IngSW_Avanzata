# Evidenze di verifica della consegna

Questa pagina raccoglie risultati riproducibili da citare nella relazione o nella presentazione. I report completi di coverage non sono versionati: vengono generati localmente e caricati come artefatti della pipeline.

## Master CI

- Workflow: [Master CI — run 29488855352](https://github.com/LucaPrevi0o/Prog_IngSW_Avanzata/actions/runs/29488855352)
- Commit verificato: `682fbe46f3f07a3293f0a2c0d9230da8ef03cbee`
- Esito: **success**
- Job completati: `Backend quality and coverage`, `Frontend quality and coverage`, `Container build and Compose validation`.

## Copertura e test

Rilevazione locale del 16 luglio 2026.

| Area | Comando | Esito | Coverage |
| --- | --- | --- | --- |
| Backend Rails | `cd backend && COVERAGE=true bundle exec rails test` | 20 run, 69 assertion, 0 failure/error | 80,26% linee (423/527), 53,07% branch (69/130) |
| Frontend Angular | `cd frontend && npm run test:ci` | 7 file, 13 test, tutti passati | 43,61% linee, 65,00% branch |

Le soglie sono rispettate: backend almeno 75% linee e 45% branch; frontend almeno 40% linee e 60% branch. I report locali sono disponibili rispettivamente in `backend/coverage/index.html` e `frontend/coverage/`; la Master CI pubblica gli artefatti `backend-coverage` e `frontend-evidence`.

## Stack Docker Compose e flusso principale

Comando eseguito:

```bash
docker compose up --build -d
docker compose ps
```

Risultato: `backend` avviato e **healthy** su `localhost:3000`; `frontend` Nginx avviato su `localhost:8080`. Entrambe le immagini sono state ricostruite dal commit verificato.

Il flusso API è stato verificato attraverso il proxy Nginx `/api`:

1. `GET http://localhost:3000/up` → health check riuscito.
2. Lettura del catalogo e selezione del prodotto con ID `1`.
3. Registrazione di un nuovo cliente → JWT ricevuto.
4. `POST /api/cart/items` → articolo aggiunto al carrello.
5. `POST /api/orders` → checkout riuscito, ordine creato con `orderId: 2`.

Per ripetere la dimostrazione dall'interfaccia, aprire `http://localhost:8080`, registrare un cliente, aggiungere un prodotto disponibile e completare il checkout. Arrestare poi lo stack con `docker compose down`; il volume `backend_storage` conserva il database finché non si usa esplicitamente `-v`.

## Riproducibilità da clone pulito

Rilevazione locale del 16 luglio 2026 in una nuova directory temporanea, creata con:

```bash
git clone --recurse-submodules https://github.com/LucaPrevi0o/Prog_IngSW_Avanzata.git shop-readiness
cd shop-readiness
cp .env.example .env
make setup
make coverage-backend
make coverage-frontend
COMPOSE_PROJECT_NAME=shop_readiness_clean \
  COMPOSE_FRONTEND_PORT=18080 COMPOSE_BACKEND_PORT=13000 \
  docker compose up --build -d
```

Il clone ha recuperato i commit fissati dal master: backend `712f9ac972c8f311099b3159876bb2430ab24e5c` e frontend `bc60aebccbe55d6466cc7fce6c8636eb3970efcf`. `make setup` ha preparato il database Rails e installato le dipendenze Angular; entrambi i comandi di coverage hanno superato le soglie. Compose ha creato e avviato correttamente i servizi sulle porte isolate `13000` e `18080`; gli endpoint `/up` e `/api/products` hanno risposto con successo. Lo stack temporaneo è stato poi arrestato con `docker compose down`.

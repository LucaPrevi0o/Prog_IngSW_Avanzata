# Applicazione Shop — Ingegneria del Software Avanzata

Questo è il repository master di un'applicazione e-commerce full-stack
sviluppata per l'esame di *Ingegneria del Software Avanzata*. Utilizza il sorgente dell'applicazione sviluppata per il corso di *Progetto di Sistemi Web*, integrando deployment tramite container e suite di test.
Riunisce un frontend Angular e un'API Ruby on Rails, mantenendo ciascuna applicazione nel
proprio repository Git.

## Struttura del repository

```text
.
├── backend/       API Ruby on Rails (sottomodulo Git)
├── frontend/      Applicazione Angular (sottomodulo Git)
├── docs/          Specifica e materiale trasversale per l'esame
├── .env.example   Modello di configurazione per lo sviluppo locale
└── Makefile       Comandi di sviluppo comuni
```

Clonare il progetto, inclusi i repository delle applicazioni, con:

```bash
git clone --recurse-submodules <master-repository-url>
```

Se il repository è stato clonato senza i sottomoduli, inizializzarli con:

```bash
git submodule update --init --recursive
```

## Architettura

Il browser carica la single-page application Angular. Il frontend invoca l'API
JSON Rails tramite HTTP; Rails persiste i dati applicativi in SQLite. L'API usa
l'autenticazione JWT e autorizza gli endpoint amministrativi in base al ruolo.

```text
Browser → Angular frontend (:4200) → Rails API (:3000) → SQLite
```

Le funzionalità principali includono consultazione e filtraggio dei prodotti,
gestione dell'account, carrello persistente, checkout e storico degli ordini,
oltre a un'area amministrativa protetta per prodotti, ordini e utenti
registrati.

## Prerequisiti

- Ruby 3.4.7 and Bundler 4
- Node.js 22 and npm 9
- SQLite 3
- GNU Make

## Sviluppo locale

Creare una sola volta il file di configurazione locale:

```bash
cp .env.example .env
```

Installare le dipendenze e preparare il database di sviluppo:

```bash
make setup
```

Avviare entrambe le applicazioni dal repository master:

```bash
make dev
```

Aprire quindi <http://localhost:4200>. L'API è in ascolto su
<http://localhost:3000>.

Usare `Ctrl+C` per arrestare entrambi i processi. `make dev` legge `.env` e
passa `FRONTEND_ORIGIN` a Rails, in modo che CORS corrisponda all'origine di
sviluppo Angular.

### Configurazione

| Impostazione | Valore predefinito | Scopo |
| --- | --- | --- |
| `FRONTEND_ORIGIN` | `http://localhost:4200` | Origine che Rails autorizza tramite CORS. |
| `API_BASE_URL` | `http://localhost:3000` | URL dell'API Angular, scritto da `make dev` nel runtime config locale. |

Durante lo sviluppo locale questi valori devono corrispondere fra loro. `.env`
non va commesso: `.env.example` è l'unica fonte dei valori predefiniti. Le
impostazioni per container e produzione saranno definite separatamente, così da
non alterare il semplice flusso di lavoro locale.

## Comandi comuni

```bash
make test             # Test unitari e di integrazione Rails
make coverage-backend # Test Rails con report SimpleCov e soglie minime
make build            # Build di produzione Angular
```

Il comando di coverage produce il report HTML in `backend/coverage/index.html` e
il risultato machine-readable in `backend/coverage/.resultset.json`. Le soglie
iniziali sono 75% per le linee e 45% per i branch.

I README del backend e del frontend contengono i comandi e i dettagli API
specifici delle singole applicazioni. Documentazione trasversale, Docker Compose
e CI risiedono nel repository master; codice applicativo e test restano nei
rispettivi sottomoduli.

La [specifica del progetto](docs/requirements.md) contiene requisiti con ID,
criteri di accettazione, tracciabilità verso implementazione/test/CI, diagramma
architetturale, panoramica dati/API e scaletta per la presentazione d'esame.

## Flusso di lavoro con i sottomoduli Git

Effettuare prima i commit del codice applicativo in `backend/` o `frontend/` e
pubblicarli nei rispettivi repository remoti; registrare poi in questo
repository il nuovo commit del sottomodulo:

```bash
git add backend frontend
git commit -m "Update application submodules"
git push
```

In questo modo le versioni esatte di frontend e backend usate per ogni consegna
d'esame rimangono riproducibili.

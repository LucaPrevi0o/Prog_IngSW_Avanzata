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
├── docs/          Specifica di progetto e materiale per l'esame (aggiunti durante il progetto)
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
| `API_BASE_URL` in `frontend/src/app/app.config.ts` | `http://localhost:3000` | URL dell'API compilato nell'applicazione Angular. |

Durante lo sviluppo locale questi valori devono corrispondere fra loro. Le
impostazioni per container e produzione saranno definite separatamente, così da
non alterare il semplice flusso di lavoro locale.

## Comandi comuni

```bash
make test     # Test unitari e di integrazione Rails
make build    # Build di produzione Angular
```

I README del backend e del frontend contengono i comandi e i dettagli API
specifici delle singole applicazioni. Documentazione trasversale, CI, copertura
dei test e definizioni dei container risiederanno in questo repository master.

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

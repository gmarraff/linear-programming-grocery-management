set Pasti; #Insieme dei Pasti cucinabili
set Ingredienti; #Insieme degl ingredienti
set Confezioni; #Insieme delle confezioni

set MacroPasti; #Raccoglitore di pasti in categorie
set PastiCategorizzati{MacroPasti}; #Pasti divisi in cateogorie

param M; #Variabile di supporto alle attivazioni logiche
param prezzi{Confezioni}; #Ogni confezione ha un suo prezzo
param disponibilita{Ingredienti}; #Indica la disponibilita di ingredienti già presente in credenza
param contenuto{Confezioni, Ingredienti}; #Ogni confezione contiene tot ingredienti per ogni tipo
param composizionePasti{Pasti, Ingredienti}; #Ogni pasto è formato da tot ingredienti
param minVarieta{MacroPasti}; #Varieta minima di pasti per macropasto
param richiestaMinimaMacroPasti{MacroPasti}; #Numero di pasti richiesti minimi per macrocategoria (solitamente 7 cena, 7 pranzo)
param richiesteMinimePasti{Pasti}; #Richieste di quantità minima di pasto nella settimana
param richiesteMinimeIngredienti{Ingredienti}; #Richieste di quantita minima di ingredienti di supporto, solitamente duraturi (Formaggio, pasta, etc)
param richiesteMassimePasti{Pasti}; #Richieste di quantità massima di pasto nella settimana

var pasti{Pasti} >= 0 integer; #Quantità di pasto scelta
var confezioni{Confezioni} >= 0 integer; #Quantità di confezioni scelte
var sceltaPasti{Pasti} binary; #Indica se il pasto è stato scelto

#L'obiettivo è di minimizzare il costo delle confezioni necessarie a comporre i pasti
minimize costo: sum{i in Confezioni} (prezzi[i]*confezioni[i]);

#Vincolo sulla varietà dei pasti
subject to st_varietaMinima {mp in MacroPasti}:
  sum {p in PastiCategorizzati[mp]} ( sceltaPasti[p] ) >= minVarieta[mp];
#Attivazione del vincolo sulla varietà dei pasti
subject to act_st_sceltaPastiUp{p in Pasti}:
  pasti[p] <= M*sceltaPasti[p];
subject to act_st_sceltaPastiLow{p in Pasti}:
  pasti[p] >= sceltaPasti[p];

#Vincolo sulla richiesta minima di MacroPasti
subject to st_minMacroPasti {mp in MacroPasti}:
  sum {p in PastiCategorizzati[mp]} ( pasti[p] ) >= richiestaMinimaMacroPasti[mp];

#Vincolo sulla richiesta minima di pasto
subject to st_richiestaMinimaPasto {p in Pasti}:
  pasti[p] >= richiesteMinimePasti[p];

#Vincolo sulla richiesta massima di pasto
subject to st_richiestaMassimaPasto {p in Pasti}:
  pasti[p] <= richiesteMassimePasti[p];
#Vincolo sulla richiesta minima di ingrediente
subject to st_richiestaMinimaIngrediente {i in Ingredienti}:
  sum {c in Confezioni} ( contenuto[c, i]*confezioni[c] ) >= richiesteMinimeIngredienti[i];

#Vincolo sulla disponibilità degli ingredienti per pasto
subject to st_ingredientiNecessari{p in Pasti, i in Ingredienti}: #per ogni ingrediente del pasto
  composizionePasti[p, i]*pasti[p] <= ( #gli ingredienti necessari alla quantita di pasto devono essere minori o uguali
    sum {c in Confezioni} ( confezioni[c]*contenuto[c, i] ) #alla somma degli ingredienti che ho acquistato
    + #aggiungendo
    disponibilita[i] #la disponibilità dell'ingrediente in credenza
    - #sottraendo
    sum {pa in Pasti: pa != p} ( pasti[pa]*composizionePasti[pa, i] ) #la somma dei pasti che voglioni cucinare contenente lo stesso ingrediente (non considerando quello corrente)
  )
;

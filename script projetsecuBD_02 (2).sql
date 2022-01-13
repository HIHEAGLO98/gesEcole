CREATE DATABASE GesEcole
ON PRIMARY 
		(  NAME = GesEcole,
			FILENAME = 'C:\TPSECUBD\GesEcole.mdf',
			SIZE = 100MB,
			MAXSIZE = 1GB,
			FILEGROWTH = 10MB
			)
LOG ON (
	NAME = GesEcole_log,
	FILENAME = 'C:\TPSECUBD\GesEcole_log.ldf',
	SIZE = 8MB,
	MAXSIZE = 1GB
	
)

GO
USE GesEcole ;

GO
CREATE TABLE ENSEIGNANT(
 numEns INT IDENTITY(1,1) NOT NULL,
 nomEns VARCHAR(30) NOT NULL,
 prenomEns VARCHAR(50),
 grade VARCHAR(25),
 anneePriseFonction VARCHAR(10) NOT NULL,
 CONSTRAINT pk_code_ens PRIMARY KEY (numEns)
)
GO
CREATE TABLE CLASSE(
codeClass VARCHAR(10) NOT NULL,
libClass VARCHAR(30) NOT NULL,
capacite INT,
CONSTRAINT check_capacite CHECK (capacite > 0),
CONSTRAINT pk_code_class PRIMARY KEY (codeClass)
)

GO
CREATE TABLE PARCOURS(
codeParc VARCHAR(10) NOT NULL,
libParc VARCHAR(50) NOT NULL,
CONSTRAINT pk_code_parc PRIMARY KEY (codeParc)
)
GO

CREATE TABLE EVALUATION(
codeEval VARCHAR(10) NOT NULL,
libEval VARCHAR(30) NOT NULL,
pourcentage INT NOT NULL,
CONSTRAINT pk_code_eval PRIMARY KEY (codeEval),
CONSTRAINT check_pourcentage CHECK (pourcentage BETWEEN 0 AND 100)
)
GO
CREATE TABLE NIVEAU(
codeNiv INT IDENTITY(1,1) NOT NULL,
libNiv VARCHAR(50) NOT NULL,
nbreModule INT ,
codeParc VARCHAR(10) NOT NULL,
CONSTRAINT pk_code_niv PRIMARY KEY (codeNiv)
)
ALTER TABLE NIVEAU ADD CONSTRAINT FK_codeParcours FOREIGN KEY (codeParc) REFERENCES PARCOURS(codeParc)

GO

CREATE TABLE MODULE(
codeMod VARCHAR(10) NOT NULL,
libMod VARCHAR(50) NOT NULL,
nbCredit INT NOT NULL,
anneeCreation INT NOT NULL,
est_requis BIT,
codeNiv INT NOT NULL,
CONSTRAINT pk_code_mod PRIMARY KEY (codeMod)
)
ALTER TABLE MODULE ADD  CONSTRAINT fk_code_niveau FOREIGN KEY(codeNiv) REFERENCES NIVEAU (codeNiv)
GO

CREATE TABLE MODULE_REQUIS(
 codeMod VARCHAR(10),
 codeModRequis VARCHAR(10),
 CONSTRAINT pk_code_requis PRIMARY KEY(codeMod,codeModRequis)
)
ALTER TABLE MODULE_REQUIS ADD CONSTRAINT fk_code_modulesR FOREIGN KEY (codeMod) REFERENCES MODULE(codeMod)
ALTER TABLE MODULE_REQUIS ADD CONSTRAINT fk_code_module_requis FOREIGN KEY(codeModRequis) REFERENCES MODULE(codeMod)

GO

CREATE TABLE DISPENSER(
codeMod VARCHAR(10) NOT NULL,
codeClass VARCHAR(10) NOT NULL,
numEns INT NOT NULL,
anneeDisp INT NOT NULL,
CONSTRAINT pk_code_dispenser PRIMARY KEY (codeMod, codeClass, numEns)
)
ALTER TABLE DISPENSER  ADD  CONSTRAINT fk_code_module FOREIGN KEY(codeMod) REFERENCES MODULE (codeMod)
ALTER TABLE DISPENSER  ADD  CONSTRAINT fk_code_classe FOREIGN KEY(codeClass) REFERENCES CLASSE (codeClass)
ALTER TABLE DISPENSER  ADD  CONSTRAINT fk_code_enseignant FOREIGN KEY(numEns) REFERENCES ENSEIGNANT (numEns)
GO

CREATE TABLE ETUDIANT(
numEtud INT IDENTITY(1,1) NOT NULL,
nomEtud VARCHAR(30) NOT NULL,
prenomEtud VARCHAR(50),
sexe CHAR(1) NOT NULL, 
dateNaissance DATE NOT NULL,
codeParc VARCHAR(10) NOT NULL,
CONSTRAINT ch_sexe CHECK (sexe IN ('M', 'F')),
--CONSTRAINT ch_age CHECK (( GETDATE() - year(dateNaissance) ) >= 17 and ( GETDATE() - year(dateNaissance) ) <= 23),
CONSTRAINT pk_code_etudiant PRIMARY KEY (numEtud)
 )
 --------------------------------------------------------
 /*Jai fait la contrainte d'age*/
 ------------------------------------------------------------------
ALTER TABLE ETUDIANT ADD CONSTRAINT ch_age CHECK (( year(GETDATE()) - year(dateNaissance) ) >= 17 and ( year(GETDATE()) - year(dateNaissance) ) <= 23);
-----------------------------------------------------------------------

ALTER TABLE ETUDIANT  ADD  CONSTRAINT fk_code_parcour FOREIGN KEY(codeParc) REFERENCES PARCOURS (codeParc)
GO

--ALTER TABLE ETUDIANT   
--DROP CONSTRAINT ch_age;  
GO 
 
CREATE TABLE INSCRIRE(
numEtud INT NOT NULL,
codeNiv INT NOT NULL,
anneeInscrire INT NOT NULL,
CONSTRAINT pk_code_inscrire PRIMARY KEY (numEtud, codeNiv)
)
ALTER TABLE INSCRIRE  ADD  CONSTRAINT fk_code_etudiant FOREIGN KEY(numEtud) REFERENCES ETUDIANT (numEtud)
ALTER TABLE INSCRIRE  ADD  CONSTRAINT fk_code_niv FOREIGN KEY(codeNiv) REFERENCES NIVEAU (codeNiv)

GO
CREATE TABLE NOTER(
 numEtud INT NOT NULL,
 codeMod VARCHAR(10),
 codeEval VARCHAR(10),
 note FLOAT ,
 valide BIT,
 dateEval DATE NOT NULL,
 CONSTRAINT pk_num PRIMARY KEY(numEtud,codeMod, codeEval),
 CONSTRAINT chek_note CHECK (note BETWEEN 0 AND 20)
)
ALTER TABLE NOTER ADD CONSTRAINT fk_code_mod FOREIGN KEY(codeMod) REFERENCES MODULE(codeMod)
ALTER TABLE NOTER ADD CONSTRAINT fk_code_etud FOREIGN KEY(numEtud) REFERENCES ETUDIANT(numEtud)
ALTER TABLE NOTER ADD CONSTRAINT fk_code_evaluation FOREIGN KEY(codeEval) REFERENCES EVALUATION(codeEval)

GO

CREATE OR ALTER TRIGGER tg_nombre_Mod
ON Module
AFTER INSERT, DELETE, UPDATE AS 
BEGIN
	INSERT INTO Niveau(nbreModule)
	select count(*) from MODULE M
	join NIVEAU N on N.codeNiv = M.codeNiv
END
GO
GO

CREATE FUNCTION Valider(@matricule int, @numNiveau int) returns char(3)
AS
BEGIN
	DECLARE @moy float;
	DECLARE @RESULT CHAR(3)
	select @moy= AVG(note*pourcentage) 
	from NOTER N
	JOIN EVALUATION E ON E.codeEval = N.codeEval
	JOIN ETUDIANT ET ON ET.numEtud = N.numEtud
	JOIN MODULE M ON M.codeMod = N.codeMod
	where M.codeNiv = @numNiveau and ET.numEtud = @matricule;
	IF (@moy >= 10)
	BEGIN
		set @RESULT = 'Oui';
	END
	ELSE
	BEGIN
		set @RESULT = 'Non';
	END
	RETURN @RESULT
END

select * from NIVEAU
/*
CREATE TABLE NOTER(
codeNote INT IDENTITY(1,1) NOT NULL,
numEtud INT NOT NULL,
codeModEval INT
note FLOAT ,
valide BIT,
CONSTRAINT pk_code_Evaluer PRIMARY KEY (codeNote),
CONSTRAINT chek_note CHECK (note BETWEEN 0 AND 20)
)
ALTER TABLE NOTER ADD CONSTRAINT chek_note CHECK (note BETWEEN 0 AND 20)
ALTER TABLE NOTER  ADD  CONSTRAINT fk_code_etud FOREIGN KEY(numEtud) REFERENCES ETUDIANT(numEtud)
ALTER TABLE NOTER  ADD  CONSTRAINT fk_code_evaluation FOREIGN KEY(codeModEval) REFERENCES MODULE_EVAL(ID)
GO*/

--Cr�ation des TRIGGERS pour les contr�les

--V�rifier qu'un �tudiant ait au moins 17 ans et au plus 23 ans � sa premi�re inscription 
--(inscription au niveau 1);
--les triggers sont à revoir les amis
-- je vais remplacer ce trigger par une contrainte
/*
CREATE OR ALTER TRIGGER tg_VerificationAge
ON  INSCRIRE
FOR INSERT 
AS
BEGIN
	DECLARE @age INT
	DECLARE @niveau INT

   SELECT @age = ( GETDATE() - year(dateNaissance) )
   FROM ETUDIANT e JOIN INSCRIRE i
   ON e.numEtud = i.codeEtud

   SELECT @niveau =  n.libNiv
   FROM NIVEAU n JOIN INSCRIRE i
   ON n.codeNiv = i.codeNiv

  IF(@age NOT IN (17, 23) AND @niveau = 'Niveau 1')
	BEGIN
		ROLLBACK 
		print('L'' �ge de l''étudiant doit �tre compris entre 17 ans et 23 ans pour le niveau 1')
	END
	
END
GO*/

--Ecrire un trigger pour faire la mise � jour automatique du nombre total de modules pour l�ann�e 
--acad�mique concern�e pour un niveau donn�;
-- bon je daccorise pour ce triggers

/*
CREATE OR ALTER TRIGGER tg_miseAjourModule
ON  MODULE
AFTER INSERT 
AS
BEGIN
	DECLARE @module INT
	DECLARE @niveau INT

	SELECT @module = COUNT(codeMod)
	FROM inserted
	SELECT @niveau = codeNiv
	FROM inserted

	UPDATE NIVEAU
	SET nbreModule = @module
	where NIVEAU.codeNiv = @niveau

END
*/
GO
--Toutefois, un module qui est un pré-requis d'autres modules ne peut être validé que par une moyenne de 12/20.
CREATE OR ALTER TRIGGER tg_module_Valider
ON NOTER
AFTER INSERT, UPDATE
AS
BEGIN
 DECLARE @moyenne_simple FLOAT;
 DECLARE @moyenne_requis FLOAT;
 DECLARE @module_requis VARCHAR(10);
 DECLARE @module_simple VARCHAR(10);
 DECLARE @notedev FLOAT;
 DECLARE @notePar FLOAT;
 DECLARE @pourcentagedev INT;
 DECLARE @pourcentagepar INT;

	 SELECT @module_requis = m.codeMod
	 FROM MODULE_EVAL join MODULE m
	 ON m.codeMod = MODULE_EVAL.codeMod
	 WHERE m.est_requis = 1

	 SELECT @module_simple = m.codeMod
	 FROM MODULE_EVAL join MODULE m
	 ON m.codeMod = MODULE_EVAL.codeMod
	 WHERE m.est_requis = 0

	 select @notedev =  n.note 
	        from NOTER n join MODULE_EVAL m 
			on n.codeModEval = m.ID 
			where m.codeEval = 'DEV'
	select @notePar = note 
	      from NOTER n join MODULE_EVAL m 
		  on n.codeModEval = m.ID 
		 where m.codeEval = 'PAR'

	select @pourcentagedev =   pourcentage 
			from EVALUATION e join MODULE_EVAL m 
			on e.codeEval = m.codeEval 
			where libEval = 'Devoirs'

   select @pourcentagepar =  pourcentage 
			from EVALUATION e join MODULE_EVAL m 
			on e.codeEval = m.codeEval 
			where libEval = 'Partiels'
	--calcul de la moyenne
	SELECT  @moyenne_requis = AVG((@notedev*@pourcentagedev) + (@notePar*@pourcentagepar) )
    from MODULE_EVAL m join NOTER n 
    on m.ID = n.codeModEval
	where m.codeMod = (SELECT codeMod FROM MODULE WHERE est_requis = 1)

	SELECT  @moyenne_simple = AVG((@notedev*@pourcentagedev) + (@notePar*@pourcentagepar) )
    from MODULE_EVAL m join NOTER n 
    on m.ID = n.codeModEval
	where m.codeMod = (SELECT codeMod FROM MODULE WHERE est_requis = 0)

 IF (@module_requis != 1 AND @moyenne_requis < 12)
	BEGIN
		UPDATE NOTER
		SET valide = 0
	END;
 IF (@module_requis = 1 AND @moyenne_requis >= 12)
	BEGIN
		update NOTER
		SET valide = 1
	END;
 IF (@module_simple !=1 and @moyenne_simple < 10)
   BEGIN
		UPDATE NOTER
		SET valide = 0
   END;
IF (@module_simple !=1 and @moyenne_simple >= 10)
   BEGIN
		UPDATE NOTER
		SET valide = 1
		
   END;
END

GO

-- Nombre total de module
CREATE OR ALTER TRIGGER tg_nbre_module
ON MODULE
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
  DECLARE @niveau VARCHAR(10);
  DECLARE @nbre int;
 
 IF EXISTS (SELECT codeNiv FROM INSERTED)
 BEGIN
	 SELECT @niveau = codeNiv FROM INSERTED;
	  SELECT @nbre = COUNT(codeMod) 
	      FROM MODULE m 
		  JOIN NIVEAU n 
		  on n.codeNiv = m.codeNiv
	     WHERE m.codeNiv = @niveau;
	    
	  UPDATE NIVEAU 
	  set nbreModule = @nbre
	  WHERE codeNiv = @niveau;
 END;
 IF EXISTS  (SELECT codeNiv FROM DELETED)
 BEGIN
	 SELECT @niveau = codeNiv FROM DELETED;
	  SELECT @nbre = COUNT(codeMod) 
	      FROM MODULE m 
		  JOIN NIVEAU n
		   on n.codeNiv = m.codeNiv
	     WHERE m.codeNiv = @niveau; 
 
	  UPDATE NIVEAU		 
	  set nbreModule = @nbre
	  WHERE codeNiv = @niveau;
 END;
END;

GO
/*
CREATE OR ALTER TRIGGER tg_chech
ON ETUDIANT
FOR INSERT, UPDATE, DELETE
AS
BEGIN
  DECLARE @user_group INT;
  IF EXISTS  (SELECT id FROM dbo.auth_user)
  SELECT @user_group  = group_id
  FROM auth_user_groups
  
END;*/

-- connections et utilisateurs --
		-- connection
create login enseignant
with password = '123456'
GO

create login directeur
with password = '123456'
GO

create login cas
with password = '123456'
GO
		--utilisateurs
create user enseignant;
GO

create user directeur;
GO
select * from sys.sysusers
create user cas;
GO
		-- autorisation
grant select, delete, insert, update
on ENSEIGNANT
to directeur;

GO
grant select, delete, insert, update
on PARCOURS
to directeur;
GO

grant select, delete, insert, update
on CLASSE
to directeur;
GO

grant select, delete, insert, update
on EVALUATION
to directeur;
GO

grant select, delete, insert, update
on NIVEAU
to directeur;
GO

grant select, delete, insert, update
on MODULE
to directeur;
GO

grant select, delete, insert, update
on EST_REQUIS
to directeur;
GO

grant select, delete, insert, update
on DISPENSER
to directeur;
GO

grant select, delete, insert, update
on ETUDIANT
to directeur;
GO

grant select, delete, insert, update
on INSCRIRE
to directeur;
GO

grant select, delete, insert, update
on MODULE_EVAL
to directeur;
GO

grant select, delete, insert, update
on NOTER
to directeur;
GO

grant select, delete, insert, update
on NOTER(codeNote,numEtud,codeModEval,note)
to enseignant;
GO

grant select, delete, insert, update
on NOTER
to cas;
GO


INSERT INTO CLASSE 
VALUES
	 ('N101','salle 1 au Nord',35),
	 ('O101','salle 1 a l''ouest',35),
	 ('sal_A','salle A',35);
GO
	 
INSERT INTO EVALUATION
VALUES
	 ('CON','Concours',0.0),
	 ('DEV ','Devoirs',40.0),
	 ('PAR','Partiels',60.0);
GO

	
INSERT INTO PARCOURS
VALUES
	 ('ITI','Ingénieur des travaux d informatique'),
	 ('LPI','Licence professionnel en informatique');
GO
select * from PARCOURS
INSERT INTO NIVEAU (libNiv,nbModules,codeParc_id) 
VALUES
	 ('Ingenieur 1',0,'ITI'),
	 ('Ingenieur 2',0,'ITI'),
	 ('Licence 1',5,'LPI'),
	 ('Licence 2',5,'LPI');
GO	

INSERT INTO MODULE (codeMod,libMod,nbCredit,est_requis,codeNiv, codeAn)
VALUES
	 ('ANG02','Anglais',3,1,4,1),
	 ('ANG1','Anglais',3,NULL,3,1),
	 ('FR_02','Francais iti',3,NULL,3,1),
	 ('FR1','Francais',3,NULL,3,1),
	 ('IFN_2','Infor iti',4,NULL,3,2);
GO

INSERT INTO EST_REQUIS(codeMod,codeModRequis) VALUES
	 ('ANG02','ANG1');

GO

INSERT INTO MODULE_EVAL(codeMod_id, codeEval_id, dateEval) 
VALUES
	('ANG02', 'DEV', '2021-02-15'),
	('ANG1', 'DEV', '2021-02-18'),
	('FR1', 'DEV', '2021-02-21'),
	('FR_02', 'DEV', '2021-02-24'),
	('ANG02', 'PAR', '2021-05-10'),
	('FR1', 'PAR', '2022-10-10');

GO 

SELECT * FROM ETUDIANT
GO
/*
--vue pour un enseignant pour  consulter ces étudiants
CREATE OR ALTER VIEW v_mes_etudiants
AS
SELECT e.numEtud AS 'etudiant_id', e.nomEtud, e.prenomEtud, e.sexe, m.libMod as 'module',
	em.codeEval as 'Evaluation', n.note, ni.codeParc 'Parcours', ni.codeNiv 'Niveau'
FROM INSCRIRE i JOIN ETUDIANT e 
	ON i.numEtud = e.numEtud JOIN NIVEAU ni
	ON i.codeNiv = ni.codeNiv JOIN MODULE m
	ON ni.codeNiv = m.codeNiv JOIN DISPENSER d
	ON m.codeMod = d.codeMod JOIN MODULE_EVAL em 
	ON d.codeMod = em.codeMod LEFT JOIN NOTER n ON n.codeModEval = em.ID 
WHERE d.codeAn = YEAR(GETDATE()) AND d.numEns = (SELECT id 
	FROM sys.sysusers u
	WHERE u.islogin = )
GO*/	

CREATE OR ALTER TRIGGER tg_note_anterieure
ON NOTER
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
  DECLARE @date VARCHAR(10);
  if EXISTS (select dateEval from inserted)
  BEGIN
	select @date = dateEval from inserted;
	if(YEAR(@date) < YEAR(GETDATE()))
	rollback;
	print('modification non autorisé');
  END;
  if EXISTS (select dateEval from deleted)
  BEGIN
	select @date = dateEval from deleted;
	if(YEAR(@date) < YEAR(GETDATE()))
	rollback;
	print('supression non autorisé');
  END;
END;
GO

-- Toute note validée par le directeur académique ne peut être modifiée que par ce dernier seul;
CREATE OR ALTER TRIGGER tg_note_valide
ON NOTER
FOR UPDATE, DELETE
AS
BEGIN
  DECLARE @valide VARCHAR(5);
  DECLARE @login_name VARCHAR(30);

  SELECT @login_name = name from sys.sysusers;
  if EXISTS (select note from inserted)
  BEGIN
	select @valide = valide from inserted;
	if(@valide = 1 and @login_name in ('Prof','chargescolarite'))
	rollback;
	print('modification non autorisé');
  END;
  if EXISTS (select note from deleted)
  BEGIN
	select @valide = valide from deleted;
	if(@valide = 1 and @login_name in ('Prof','chargescolarite'))
	rollback;
	print('supression non autorisé');
  END;
END;
GO

SELECT CURRENT_USER;

select SYSTEM_USER;
select name from sys.sysusers

--creation des logins
create login DG
with password = '12345678',
DEFAULT_DATABASE= GesEcoleFinale;

GO
create login Prof
with password = '12345678',
DEFAULT_DATABASE= GesEcoleFinale;
GO
create login chargescolarite
with password = '12345678',
DEFAULT_DATABASE= GesEcoleFinale;
GO

ALTER LOGIN DG ENABLE;
ALTER LOGIN Prof ENABLE
ALTER LOGIN chargescolarite ENABLE
--Utilisateur
CREATE USER kevin
FOR LOGIN DG;

ALTER USER kevin
WITH NAME = DG

CREATE USER translucide
FOR LOGIN Prof;

ALTER USER translucide
WITH NAME = Prof

CREATE USER samuel
FOR LOGIN chargescolarite;

ALTER USER samuel
WITH NAME = chargescolarite

--PRIVILEGES
--DIRECTEUR KEVIN
GRANT SELECT, DELETE, INSERT, UPDATE
ON NOTER
TO DG;
GO

GRANT SELECT, DELETE, INSERT, UPDATE
ON ETUDIANT
TO DG;
GO
GRANT SELECT, DELETE, INSERT, UPDATE
ON ENSEIGNANT
TO DG;
GO

GRANT SELECT, DELETE, INSERT, UPDATE
ON MODULE
TO DG;
GO
GRANT SELECT, DELETE, INSERT, UPDATE
ON MODULES_REQUIS
TO DG;
GO
GRANT SELECT, DELETE, INSERT, UPDATE
ON NIVEAU
TO DG;
GO
GRANT SELECT, DELETE, INSERT, UPDATE
ON PARCOURS
TO DG;
GO
GRANT SELECT, DELETE, INSERT, UPDATE
ON CLASSE
TO DG;
GO
GRANT SELECT, DELETE, INSERT, UPDATE
ON DISPENSER
TO DG;
GO
GRANT SELECT, DELETE, INSERT, UPDATE
ON EVALUATION
TO DG;
GO
GRANT SELECT, DELETE, INSERT, UPDATE
ON INSCRIRE
TO DG;
GO
--ENSEIGNANT translucide

GRANT SELECT, INSERT,UPDATE
ON NOTER
TO Prof;
GO

GRANT SELECT 
ON ETUDIANT
TO chargescolarite

REVOKE UPDATE
ON NOTER
FROM Prof
GO

--CHARGER DE LA SCOLARITE samuel
GRANT SELECT, DELETE, INSERT, UPDATE
ON NOTER
TO chargescolarite;
GO
select * from ETUDIANT
GRANT CONNECT TO guest

------------------------------------------FIN------------------------------------------------------------
SELECT s.name as 'Connexion', p.name as 'Utilisateur'
FROM sys.database_principals p
INNER JOIN sys.server_principals s
ON s.sid = p.sid;
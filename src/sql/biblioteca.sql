CREATE DATABASE BIBLIOTECA
GO
USE BIBLIOTECA
GO

CREATE TABLE BIB_AUTORES(
AUT_IN_ID INT NOT NULL IDENTITY CONSTRAINT BIB_PK_AUTOR PRIMARY KEY,
AUT_ST_NOME VARCHAR(20) NOT NULL,
AUT_ST_SOBRENOME VARCHAR(50) NOT NULL,
);

CREATE TABLE BIB_EDITORA(
EDI_IN_ID INT NOT NULL IDENTITY CONSTRAINT BIB_PK_EDITORA PRIMARY KEY,
EDI_ST_NOME VARCHAR(50) NOT NULL,
);

CREATE TABLE BIB_LIVRO(
LIV_IN_ID INT NOT NULL IDENTITY CONSTRAINT BIB_PK_LIVRO PRIMARY KEY,
LIV_ST_TITULO VARCHAR(100) NOT NULL,
LIV_CH_ISBN CHAR(8) NOT NULL CONSTRAINT BIB_CK_LIV_ISBN CHECK (LIV_CH_ISBN LIKE
							'[0-9][0-9][-][0-9][0-9][0-9][0-9]')
							CONSTRAINT BIB_UK_LIV_ISBN UNIQUE,
LIV_DT_PUBLICACAO DATE NOT NULL,
LIV_RE_PRECO NUMERIC(10, 2) NOT NULL CONSTRAINT BIB_DF_LIV_PRECO DEFAULT 0
									 CONSTRAINT BIB_CK_LIV_PRECO CHECK (LIV_RE_PRECO>=0),
LIV_IN_ID_AUTOR INT NOT NULL,
LIV_IN_ID_EDITORA INT NOT NULL
);

ALTER TABLE BIB_LIVRO
	ADD CONSTRAINT BIB_FK_LIV_AUTOR FOREIGN KEY (LIV_IN_ID_AUTOR) REFERENCES BIB_AUTORES (AUT_IN_ID)
ALTER TABLE BIB_LIVRO
	ADD CONSTRAINT BIB_FK_LIV_EDITORA FOREIGN KEY (LIV_IN_ID_EDITORA) REFERENCES BIB_EDITORA (EDI_IN_ID)

--INSERT

INSERT INTO BIB_LIVRO (LIV_ST_TITULO, LIV_CH_ISBN, LIV_DT_PUBLICACAO, LIV_RE_PRECO, LIV_IN_ID_AUTOR, LIV_IN_ID_EDITORA)
VALUES ('Java - como programar', '13-7272', '20090210', 50.60, 1, 2);

INSERT INTO BIB_LIVRO (LIV_ST_TITULO, LIV_CH_ISBN, LIV_DT_PUBLICACAO, LIV_RE_PRECO, LIV_IN_ID_AUTOR, LIV_IN_ID_EDITORA)
VALUES ('Java 6', '12-4566', '20020907', 50.60, 2, 1);

INSERT INTO BIB_AUTORES (AUT_ST_NOME, AUT_ST_SOBRENOME) VALUES ('José', 'Silva')
INSERT INTO BIB_AUTORES (AUT_ST_NOME, AUT_ST_SOBRENOME) VALUES ('Felipe', 'Souza')

INSERT INTO BIB_EDITORA(EDI_ST_NOME) VALUES('Terra')
INSERT INTO BIB_EDITORA(EDI_ST_NOME) VALUES('Planeta')

SELECT * FROM BIB_LIVRO
INNER JOIN BIB_EDITORA
ON BIB_LIVRO.LIV_IN_ID_EDITORA = BIB_EDITORA.EDI_IN_ID



/*
*******************************************
* STORED PROCEDURE DE INSERT LIVRO
*******************************************
*/

CREATE OR ALTER PROCEDURE SP_I_BIB_LIVRO
(@titulo varchar(100), @isbn char(14), @publicacao date, @preco numeric(10,2), @idautor int, @ideditora int)
AS
DECLARE @TOTAL_LIVRO INT

SELECT @TOTAL_LIVRO = COUNT(*) FROM BIB_LIVRO WHERE LIV_CH_ISBN = @isbn;
IF(@TOTAL_LIVRO > 0)
	BEGIN
		RAISERROR('O código ISBN´informado já existe', 15,1)
		RETURN
	END
IF(@isbn NOT LIKE '[0-9][0-9][-][0-9][0-9][0-9][0-9]')
	BEGIN
		RAISERROR('O formato do ISBN deve ser 99-9999', 15,1)
		RETURN
	END
IF(@preco < 0)
	BEGIN
		RAISERROR('O preço do livro deve ser maior ou igual a 0', 15,1)
		RETURN
	END

IF(LEN(TRIM(@titulo))=0)
	BEGIN
		RAISERROR('O campo do título do livro é obrigatório', 15,1)
		RETURN
	END

INSERT INTO BIB_LIVRO (LIV_ST_TITULO, LIV_CH_ISBN, LIV_DT_PUBLICACAO, LIV_RE_PRECO, LIV_IN_ID_AUTOR, LIV_IN_ID_EDITORA)
VALUES (@titulo, @isbn, @publicacao, @preco, @idautor, @ideditora);

/*
*******************************************
* STORED PROCEDURE DE SELECT LIVRO
*******************************************
*/

CREATE OR ALTER PROCEDURE SP_S_BIB_LIVRO
(@filtro varchar(100) ='')
AS
IF(LEN(TRIM(@filtro))=0)
	BEGIN
		SELECT

		LIV_ST_TITULO AS 'Título',
		LIV_CH_ISBN AS 'CódigoISBN',
		LIV_RE_PRECO AS 'Preço',
		FORMAT(LIV_DT_PUBLICACAO, 'dd/MM/yyyy') AS 'Publicação',
		LIV_IN_ID_AUTOR AS  'Id Autor',
		LIV_IN_ID_EDITORA AS 'Id editora'
		FROM
			BIB_LIVRO
		END
ELSE
	BEGIN
		SELECT
		LIV_IN_ID AS 'Id livro',
		LIV_ST_TITULO AS 'Título',
		LIV_CH_ISBN AS 'CódigoISBN',
		LIV_RE_PRECO AS 'Preço',
		FORMAT(LIV_DT_PUBLICACAO, 'dd/MM/yyyy') AS 'Publicação',
		LIV_IN_ID_AUTOR AS  'Id Autor',
		LIV_IN_ID_EDITORA AS 'Id editora'
		FROM
			BIB_LIVRO	
		WHERE LIV_ST_TITULO LIKE '%'+@filtro+'%' OR
		LIV_IN_ID_AUTOR LIKE '%'+@filtro+'%'
	END
RETURN

/*
*******************************************
* STORED PROCEDURE DE DELETE LIVRO
*******************************************
*/

CREATE OR ALTER PROCEDURE SP_D_BIB_LIVRO
@id int
AS
DECLARE @TOTAL_LIVRO INT

SELECT @TOTAL_LIVRO = COUNT(LIV_IN_ID) FROM BIB_LIVRO WHERE LIV_IN_ID = @id

IF(@TOTAL_LIVRO < 1)
	BEGIN
		RAISERROR('O id informado não existe', 15,1)
		RETURN
	END

DELETE FROM BIB_LIVRO WHERE LIV_IN_ID = @id
RETURN
GO

/*
*******************************************
* STORED PROCEDURE DE UPDATE LIVRO
*******************************************
*/


CREATE OR ALTER PROCEDURE SP_U_BIB_LIVRO
(@id int, @isbn char(14), @titulo varchar(100), @preco numeric(10,1), @publicacao date, @idautor int, @ideditora int)
AS

SET NOCOUNT ON
DECLARE @TOTAL_LIVRO INT
SELECT @TOTAL_LIVRO = COUNT(LIV_CH_ISBN) FROM BIB_LIVRO 
WHERE LIV_CH_ISBN = @isbn AND LIV_IN_ID <> @id

IF(@TOTAL_LIVRO > 0)
	BEGIN
		RAISERROR('O código ISBN já existe', 15,1)
		RETURN
	END

IF(@preco < 0)
	BEGIN
		RAISERROR('O preço deve ser um valor positivo', 15,1)
		RETURN
	END

IF(@isbn NOT LIKE '[0-9][0-9][-][0-9][0-9][0-9][0-9]')
	BEGIN
		RAISERROR('O código ISBN não está no formato', 15,1)
		RETURN
	END

IF(LEN(TRIM(@titulo))=0)
	BEGIN
		RAISERROR('O titulo do livro é obrigatório', 15,1)
		RETURN
	END

DECLARE @TOTAL_LIVROS INT
SELECT @TOTAL_LIVROS = COUNT(LIV_IN_ID) FROM BIB_LIVRO WHERE LIV_IN_ID = @id

IF(@TOTAL_LIVROS < 1)
	BEGIN
		RAISERROR('O id informado não existe', 15,1)
		RETURN
	END

UPDATE BIB_LIVRO SET LIV_ST_TITULO = @titulo,
					 LIV_CH_ISBN = @isbn,
					 LIV_RE_PRECO = @preco,
					 LIV_DT_PUBLICACAO = @publicacao,
					 LIV_IN_ID_AUTOR = @idautor,
					 LIV_IN_ID_EDITORA = @ideditora

				WHERE
					LIV_IN_ID = @id
				RETURN
GO


/*
*******************************************
* STORED PROCEDURE DE INSERT AUTORES
*******************************************
*/

CREATE OR ALTER PROCEDURE SP_I_BIB_AUTORES
(@nome varchar(20), @sobrenome varchar(50))
AS
DECLARE @TOTAL_AUTORES INT
SELECT @TOTAL_AUTORES = COUNT(*) FROM  BIB_AUTORES WHERE AUT_ST_NOME = @nome
IF(@TOTAL_AUTORES > 0)
	BEGIN
		RAISERROR('O nome informado já existe', 15,1)
		RETURN
	END

IF(LEN(TRIM(@nome))=0)
	BEGIN
		RAISERROR('O campo nome é obrigatório', 15,1)
		RETURN
	END

INSERT INTO BIB_AUTORES(AUT_ST_NOME, AUT_ST_SOBRENOME) VALUES(@nome, @sobrenome)
GO

/*
*******************************************
* STORED PROCEDURE DE SELECT AUTORES
*******************************************
*/

CREATE OR ALTER PROCEDURE SP_S_BIB_AUTORES
(@filtro varchar(100)='')
AS
IF(LEN(TRIM(@filtro))=0)
	BEGIN
		SELECT 
			AUT_IN_ID AS 'ID',
			AUT_ST_NOME AS 'Nome',
			AUT_ST_SOBRENOME AS 'Sobrenome'
			FROM
				BIB_AUTORES
	END
ELSE
	BEGIN
		SELECT
		AUT_IN_ID AS 'Id autor',
		AUT_ST_NOME AS 'Nome',
		AUT_ST_SOBRENOME AS 'Sobrenome'
		FROM
			BIB_AUTORES
		WHERE AUT_ST_NOME LIKE '%'+@filtro+'%' OR
		AUT_ST_SOBRENOME LIKE '%'+@filtro+'%'
	END
RETURN
GO

/*
*******************************************
* STORED PROCEDURE DE DELETE AUTORES
*******************************************
*/

CREATE OR ALTER PROCEDURE SP_D_BIB_AUTORES
@id int
AS
DECLARE @TOTAL_AUTORES INT
SELECT @TOTAL_AUTORES = COUNT(AUT_IN_ID) FROM BIB_AUTORES WHERE AUT_IN_ID = @id

IF(@TOTAL_AUTORES < 1)
	BEGIN
		RAISERROR('O id informado não existe',15,1)
		RETURN
	END
DELETE FROM BIB_AUTORES WHERE AUT_IN_ID = @id
RETURN
GO

/*
*******************************************
* STORED PROCEDURE DE UPDATE AUTORES
*******************************************
*/

CREATE OR ALTER PROCEDURE SP_U_BIB_AUTORES
(@id int, @nome varchar(20), @sobrenome varchar(50))
AS
DECLARE @TOTAL_SOBRENOME VARCHAR(50)
SELECT @TOTAL_SOBRENOME = COUNT(AUT_ST_SOBRENOME) FROM BIB_AUTORES 
WHERE AUT_ST_SOBRENOME = @sobrenome AND  AUT_IN_ID = @id

IF(@TOTAL_SOBRENOME > 0)
	BEGIN
		RAISERROR('O sobrenome informado já existe', 15,1)
		RETURN
	END

IF (LEN(TRIM(@nome))=0)
	BEGIN
		RAISERROR('O nome do produto é obrigatório', 15,1)
		RETURN
	END

DECLARE @TOTAL_AUTORES INT
SELECT @TOTAL_AUTORES = COUNT(AUT_IN_ID) FROM BIB_AUTORES 
WHERE AUT_IN_ID = @id

IF(@TOTAL_AUTORES < 1)
	BEGIN
		RAISERROR('O id informado não existe', 15,1)
		RETURN
	END

UPDATE BIB_AUTORES
SET	AUT_ST_NOME = @nome,
	AUT_ST_SOBRENOME = @sobrenome
WHERE
	AUT_IN_ID = @id
RETURN
GO

/*
*******************************************
* STORED PROCEDURE DE INSERT EDITORA
*******************************************
*/

CREATE OR ALTER PROCEDURE SP_I_BIB_EDITORA
(@nome varchar(50))
AS
DECLARE @TOTAL_EDITORA INT
SELECT @TOTAL_EDITORA = COUNT(*) FROM BIB_EDITORA WHERE EDI_ST_NOME = @nome
IF(@TOTAL_EDITORA > 0)
	BEGIN
		RAISERROR('O nome inserido já existe', 15,1)
		RETURN
	END
IF(LEN(TRIM(@nome))=0)
	BEGIN
		RAISERROR('O campo nome da editora é obrigatório', 15,1)
		RETURN
	END

INSERT INTO BIB_EDITORA(EDI_ST_NOME) VALUES (@nome)
GO

/*
*******************************************
* STORED PROCEDURE DE SELECT EDITORA
*******************************************
*/


CREATE OR ALTER PROCEDURE SP_S_BIB_EDITORA
(@filtro varchar(100)='')
AS
IF(LEN(TRIM(@filtro))=0)
	BEGIN
		SELECT
			EDI_IN_ID AS 'Id',
			EDI_ST_NOME AS 'Nome'
			FROM
				BIB_EDITORA
	END
ELSE
	BEGIN
		SELECT
			EDI_IN_ID AS 'Id',
			EDI_ST_NOME AS 'Nome'
			FROM
				BIB_EDITORA
			WHERE EDI_ST_NOME LIKE '%'+@filtro+'%'
	END
RETURN
GO

/*
*******************************************
* STORED PROCEDURE DE DELETE EDITORA
*******************************************
*/

USE BIBLIOTECA
GO

CREATE OR ALTER PROCEDURE SP_D_BIB_EDITORA
(@id int)
AS
DECLARE @TOTAL_EDITORA INT
SELECT @TOTAL_EDITORA = COUNT(EDI_IN_ID) FROM BIB_EDITORA
WHERE EDI_IN_ID = @id

IF(@TOTAL_EDITORA < 1)
	BEGIN
		RAISERROR('O id não existe', 15,1)
		RETURN
	END

DELETE FROM BIB_EDITORA WHERE EDI_IN_ID = @id
RETURN
GO

CREATE OR ALTER PROCEDURE SP_U_BIB_EDITORA
@id int, @nome varchar(50)
AS
IF(LEN(TRIM(@nome))=0)
	BEGIN
		RAISERROR('O nome da editora é obrigatório',15,1);
	RETURN
END

DECLARE @TOTAL_EDITORA INT
SELECT @TOTAL_EDITORA = COUNT(EDI_IN_ID) FROM BIB_EDITORA WHERE EDI_IN_ID = @id;
IF(@TOTAL_EDITORA < 1)
	BEGIN
		RAISERROR('O id informado já existe',15,1);
		RETURN
	END
UPDATE BIB_EDITORA
SET EDI_ST_NOME = @nome
WHERE
	EDI_IN_ID = @id
RETURN


CREATE FUNCTION itens (@valor REAL)
RETURNS TABLE
AS
RETURN(
	SELECT * FROM BIB_LIVRO
	INNER JOIN BIB_AUTORES
	ON BIB_LIVRO.LIV_IN_ID_AUTOR = BIB_AUTORES.AUT_IN_ID
	WHERE LIV_RE_PRECO > @valor
)

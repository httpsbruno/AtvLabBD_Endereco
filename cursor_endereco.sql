CREATE DATABASE cursor_endereco
GO
USE cursor_endereco

CREATE  TABLE envio(
CPF             VARCHAR(20),
NR_LINHA_ARQUIV	INT,
CD_FILIAL       INT,
DT_ENVIO        DATETIME,
NR_DDD          INT,
NR_TELEFONE	    VARCHAR(10),
NR_RAMAL        VARCHAR(10),
DT_PROCESSAMENT	datetime,
NM_ENDERECO     VARCHAR(200),
NR_ENDERECO     INT,
NM_COMPLEMENTO	VARCHAR(50),
NM_BAIRRO       VARCHAR(100),
NR_CEP          VARCHAR(10),
NM_CIDADE       VARCHAR(100),
NM_UF           VARCHAR(2),
)

CREATE TABLE endereço(
CPF         VARCHAR(20),
CEP	        VARCHAR(10),
PORTA	    INT,
ENDEREÇO	VARCHAR(200),
COMPLEMENTO	VARCHAR(100),
BAIRRO	    VARCHAR(100),
CIDADE	    VARCHAR(100),
UF          VARCHAR(2)
)

create procedure sp_insereenvio
as
declare @cpf as int
declare @cont1 as int
declare @cont2 as int
declare @conttotal as int
set @cpf = 11111
set @cont1 = 1
set @cont2 = 1
set @conttotal = 1
	while @cont1 <= @cont2 and @cont2 < = 100
			begin
				insert into envio (CPF, NR_LINHA_ARQUIV, DT_ENVIO)
				values (cast(@cpf as varchar(20)), @cont1,GETDATE())
				insert into endereço (CPF,PORTA,ENDEREÇO)
				values (@cpf,@conttotal,CAST(@cont2 as varchar(3))+'Rua '+CAST(@conttotal as varchar(5)))
				set @cont1 = @cont1 + 1
				set @conttotal = @conttotal + 1
				if @cont1 > = @cont2
					begin
						set @cont1 = 1
						set @cont2 = @cont2 + 1
						set @cpf = @cpf + 1
					end
	end

EXEC sp_insereenvio

SELECT * FROM envio ORDER BY CPF,NR_LINHA_ARQUIV ASC
SELECT * FROM endereço ORDER BY CPF ASC

CREATE PROCEDURE sp_insere_endereco
AS
BEGIN
	DECLARE @CPF                          VARCHAR(20),
			@NR_LINHA_ARQUIV              INT,
			@PORTA                        INT,
			@ENDEREÇO                     VARCHAR(200),
			@CONT			              INT,
			@STATUS_CURSOR_ENVIO		  INT,
			@STATUS_CURSOR_ENDERECO		  INT
	
	SET @CONT = 0
	--CURSOR ENVIO
    DECLARE cursor_buscaenvio CURSOR FOR SELECT NR_LINHA_ARQUIV,CPF  FROM envio 
    OPEN cursor_buscaenvio
    FETCH NEXT FROM cursor_buscaenvio INTO @NR_LINHA_ARQUIV,@CPF
	SET @STATUS_CURSOR_ENVIO = @@FETCH_STATUS
	
	WHILE (@STATUS_CURSOR_ENVIO = 0)
    BEGIN
		--CURSOR ENDEREÇO
		DECLARE cursor_buscaendereco CURSOR FOR SELECT ENDEREÇO, PORTA FROM endereço 
		OPEN cursor_buscaendereco
		FETCH NEXT FROM cursor_buscaendereco INTO @ENDEREÇO, @PORTA
		SET @STATUS_CURSOR_ENDERECO = @@FETCH_STATUS

		
			WHILE (@CONT != @NR_LINHA_ARQUIV AND @STATUS_CURSOR_ENDERECO = 0)
			BEGIN
				SET @CONT += 1

				IF(@CONT = @NR_LINHA_ARQUIV)
				BEGIN
					UPDATE envio SET  NM_ENDERECO=@ENDEREÇO, NR_ENDERECO = @PORTA
					WHERE CPF = @CPF AND NR_LINHA_ARQUIV = @NR_LINHA_ARQUIV
				END

				FETCH NEXT FROM cursor_buscaendereco INTO @ENDEREÇO, @PORTA
				SET @STATUS_CURSOR_ENDERECO = @@FETCH_STATUS
				
			END
		
		SET @CONT = 0
		CLOSE cursor_buscaendereco
		DEALLOCATE cursor_buscaendereco
		
		--INCREMENTO DO CURSOR ENVIO
        FETCH NEXT FROM cursor_buscaenvio INTO @NR_LINHA_ARQUIV,@CPF
		SET @STATUS_CURSOR_ENVIO = @@FETCH_STATUS
	END

	CLOSE cursor_buscaenvio
    DEALLOCATE cursor_buscaenvio
END

EXEC sp_insere_endereco

SELECT * FROM envio ORDER BY CPF,NR_LINHA_ARQUIV ASC
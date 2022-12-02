defmodule Nux.Csv do
  require Explorer.DataFrame

  def is_card?(content) do
    String.starts_with?(content, "date,category,title,amount")
  end

  def load_csv(content) do
    with {:ok, dataframe} <- Explorer.DataFrame.load_csv(content) do
      if is_card?(content) do
        dataframe
        |> Explorer.DataFrame.to_rows()
        |> Enum.map(fn row ->
          date = Date.from_iso8601!(row["date"])
          %{row | "date" => date, "amount" => -row["amount"]}
        end)
      else
        dataframe
        |> Explorer.DataFrame.rename([:date, :amount, :category, :title])
        |> Explorer.DataFrame.mutate(category: "")
        |> Explorer.DataFrame.to_rows()
        |> Enum.map(fn row ->
          [day, month, year] = String.split(row["date"], "/")

          date =
            Date.new!(String.to_integer(year), String.to_integer(month), String.to_integer(day))

          %{row | "date" => date}
        end)
      end
    end
  end

  def load_and_flatten(contents) do
    contents
    |> Enum.map(&load_csv/1)
    |> List.flatten()
  end

  def get_categories(grouped) do
    grouped |> Map.keys() |> Enum.map(fn {cat, _month} -> cat end) |> Enum.uniq() |> Enum.sort()
  end

  def get_months(grouped) do
    grouped |> Map.keys() |> Enum.map(fn {_cat, month} -> month end) |> Enum.uniq() |> Enum.sort()
  end

  def categories() do
    %{
      "Posto Dois Irmaos" => "transporte",
      "Unidas Locadora" => "viagem",
      "Locomotiva Irish Pub" => "restaurante",
      "Unidas Locadora 2/6" => "viagem",
      "Sc-Pointerivoli" => "viagem",
      "Meridiam Burguer" => "restaurante",
      "IOF de \"Sc-Pointerivoli\"" => "viagem",
      "Carvalho Super Sao Seb" => "supermercado",
      "Quiosque do Nana" => "restaurante",
      "Suzan Christine Vogt" => "restaurante",
      "Transferência enviada pelo Pix - JAIME FERNANDES DO RIO - 667.046.857-15 - CAIXA ECONOMICA FEDERAL (0104) Agência: 1344 Conta: 1288000000970293673-5" =>
        "casa",
      "Transferência enviada pelo Pix - André Lucas Pinheiro Veloso Cavalcante - 354.797.298-10 - BCO C6 S.A. (0336) Agência: 1 Conta: 9066260-1" =>
        "lazer",
      "Pg *Jamesdelivery Jame" => "supermercado",
      "Posto Mais Sao Sebasti" => "transporte",
      "Pagamento da fatura - Cartão Nubank" => "cartao",
      "Pagamento de boleto efetuado - VIVO - GVT" => "serviços",
      "Pareo" => "restaurante",
      "Gol Transp A*Rxafjj017" => "viagem",
      "Pg *Ingresso Rapido Mo" => "lazer",
      "Transferência recebida pelo Pix - RUBENS NERY COSTA - 138.658.113-53 - BCO DO BRASIL S.A. (0001) Agência: 3178 Conta: 47912-8" =>
        "outros",
      "Compra no débito - Mp *Taylson" => "outros",
      "Transferência enviada pelo Pix - GENTIL FERREIRA DA SILVA NETO - 656.693.553-34 - BCO DO BRASIL S.A. (0001) Agência: 1640 Conta: 510134615-9" =>
        "outros",
      "Gf4 Participacoes" => "restaurante",
      "Posto Paraiso" => "transporte",
      "American Cookies" => "restaurante",
      "Deposito Mais" => "supermercado",
      "Raia" => "saúde",
      "F J Buffet" => "restaurante",
      "Mercado Barramares" => "supermercado",
      "Galicia Comercio de de" => "transporte",
      "Ebanx*Spotify" => "serviços",
      "Pag*Siribolo" => "restaurante",
      "Pag*Romulodoamaral" => "serviços",
      "Transferência enviada pelo Pix - JOSE ADENAUER CASTELO BRANCO SOUSA - 226.458.533-15 - CAIXA ECONOMICA FEDERAL (0104) Agência: 1989 Conta: 1288000000777523592-7" =>
        "serviços",
      "Pv Impoted" => "eletrônicos",
      "Drogarias Carioca" => "saúde",
      "Ebanx *Rentngcarz 1/4" => "viagem",
      "Latam Site 2/4" => "viagem",
      "Transferência enviada pelo Pix - EQUATORIAL PIAUI - 06.840.748/0001-89 - BCO DO BRASIL S.A. (0001) Agência: 3309 Conta: 15665-5" =>
        "casa",
      "Transferência enviada - Alexandre Marangoni Costa - 036.777.193-48 - XP Investimentos Corretora de Câmbio Títulos e Valores Mobiliários S.A. (0102) Agência: 2 Conta: 245488-1" =>
        "investimento",
      "Airbnb Pagam*Airbnb *" => "viagem",
      "Transferência enviada pelo Pix - Ângela Rodrigues de Sousa - 007.485.483-60 - NU PAGAMENTOS - IP (0260) Agência: 1 Conta: 8334526-4" =>
        "lazer",
      "Posto Martinez Ltda" => "transporte",
      "Pagamento de boleto efetuado - EQUATORIAL PIAUI DISTRIBUIDORA DE ENERGIA S.A" => "casa",
      "Metro Rj" => "transporte",
      "Pag*Jambalayarestaura" => "restaurante",
      "IOF de \"Sq Tours\"" => "viagem",
      "Amazon.Com.Br" => "eletrônicos",
      "Transferência enviada pelo Pix - JOSIMEIRE DA COSTA ARAUJO - 888.686.213-04 - CAIXA ECONOMICA FEDERAL (0104) Agência: 29 Conta: 1288000000756874752-3" =>
        "serviços",
      "Autoroute Du Sud" => "viagem",
      "Transferência enviada pelo Pix - SECRETARIA DA RECEITA FEDERAL DO BRASIL - 00.394.460/0058-87 - BCO DO BRASIL S.A. (0001) Agência: 1607 Conta: 333666-2" =>
        "imposto",
      "Transferência enviada - Alexandre Marangoni Costa - 036.777.193-48 - Easynvest - Título Corretora de Valores SA (0140) Agência: 1 Conta: 5699856-0" =>
        "investimento",
      "IOF de \"Surf Ski Shop\"" => "viagem",
      "Brioche Doree" => "restaurante",
      "Transferência enviada pelo Pix - RICARDO ALBERTINI CHAGAS - 014.649.601-94 - BCO DO BRASIL S.A. (0001) Agência: 2901 Conta: 510016914-8" =>
        "viagem",
      "Chateau Du Vin" => "restaurante",
      "Sushimar Barra" => "restaurante",
      "Aeromate" => "restaurante",
      "Zus Bistro" => "restaurante",
      "Unidas Locadora 1/6" => "viagem",
      "Pp*Paypal *Ingre" => "lazer",
      "Pag*Newpag" => "lazer",
      "Berg Barbearia" => "serviços",
      "Bebelu Sanduiches" => "restaurante",
      "Posto-2653" => "transporte",
      "Pastel Ichiban" => "restaurante",
      "Bondinho Pao*Bondinho" => "viagem",
      "Pagamento recebido" => "cartao",
      "Crédito de \"FREE MOBILE\"" => "viagem",
      "IOF de \"Hotel Vendome\"" => "viagem",
      "Jl Comercio" => "supermercado",
      "Transferência recebida pelo Pix - MARINA MARANGONI COSTA BRAGA - 632.120.133-20 - ITAÚ UNIBANCO S.A. (0341) Agência: 3820 Conta: 742-9" =>
        "outros",
      "Vanice Pereira de Alm" => "supermercado",
      "Smiles Fidel*Txaembarq" => "viagem",
      "Transferência enviada pelo Pix - Erlon Sales Cavalcante Vieira - 031.946.613-29 - NU PAGAMENTOS - IP (0260) Agência: 1 Conta: 97339653-3" =>
        "serviços",
      "Favorito Empreendiment" => "restaurante",
      "Transferência enviada pelo Pix - JOAO PEDRO BERWANGER - 131.455.957-50 - ITAÚ UNIBANCO S.A. (0341) Agência: 4095 Conta: 10643-3" =>
        "lazer",
      "Compra no débito - Posto Aguia" => "transporte",
      "IOF de \"Total Mkt Fr\"" => "viagem",
      "Transferência enviada pelo Pix - MARIEL NUNES ARQUITETURA LTDA - 38.232.494/0001-02 - NU PAGAMENTOS - IP (0260) Agência: 1 Conta: 85305300-8" =>
        "mariel",
      "Nobre Sabores" => "restaurante",
      "Loja Aguia" => "lazer",
      "Pagamento de boleto efetuado - VIVO - RJ" => "serviços",
      "Transferência recebida pelo Pix - MARANGONI COSTA LTDA - 42.546.422/0001-07 - BANCO INTER (0077) Agência: 1 Conta: 14269605-6" =>
        "recebido",
      "Transferência enviada pelo Pix - IVAN LEITUGA C PELLON MIRANDA - 136.039.277-70 - ITAÚ UNIBANCO S.A. (0341) Agência: 6014 Conta: 29439-8" =>
        "lazer",
      "Tarifa - Saque" => "lazer",
      "Pagamento de boleto efetuado - DAS - Simples Nacional" => "imposto",
      "Compra no débito - Pes e Lanches" => "restaurante",
      "Uber *Uber *Trip" => "transporte",
      "Ifood *Ifood" => "ifood",
      "Estorno - Transferência enviada pelo Pix - Eduardo Costa Carvalho - 988.163.733-34 - NU PAGAMENTOS - IP (0260) Agência: 1 Conta: 3749491-8" =>
        "outros",
      "Transferência recebida pelo Pix - INACIO LIMA LYSANDRO MARTINS - 139.368.857-88 - BCO SANTANDER (BRASIL) S.A. (0033) Agência: 3630 Conta: 1082403-4" =>
        "lazer",
      "Transferência Recebida - Mariel Nunes de Sousa - 003.962.473-00 - NU PAGAMENTOS - IP (0260) Agência: 1 Conta: 77621649-2" =>
        "mariel",
      "Pagamento de boleto efetuado - Multas de Transito (Codigo da Instituicao   5936)" =>
        "transporte",
      "Tokio" => "restaurante",
      "la Trufel" => "restaurante",
      "Zio Cucina" => "restaurante",
      "Pagamento de boleto efetuado - DETRAN REC CODIGO BARRAS" => "transporte",
      "Sq Tours" => "viagem",
      "Pao de Acucar-0310" => "supermercado",
      "Parente Araujo Combust" => "transporte",
      "Transferência enviada pelo Pix - Eduardo Costa Carvalho - 988.163.733-34 - NU PAGAMENTOS - IP (0260) Agência: 1 Conta: 3749491-8" =>
        "outros",
      "IOF de \"Autoroute Du Sud\"" => "viagem",
      "Transferência enviada pelo Pix - RODOLFO JACINTO SILVA 03765214140 - 33.694.698/0001-41 - BRB - BCO DE BRASILIA S.A. (0070) Agência: 201 Conta: 201042892-1" =>
        "lazer",
      "Emporio Deli" => "supermercado",
      "Restaurante Pedra" => "restaurante",
      "Cacique Petroleo" => "transporte",
      "Transferência recebida pelo Pix - GUILHERME N COSTA - 867.667.167-20 - BCO DO BRASIL S.A. (0001) Agência: 3178 Conta: 75333-5" =>
        "outros",
      "Vasto" => "restaurante",
      "P Cacique" => "transporte",
      "Frango Leste" => "restaurante",
      "Posto 2653 Dom Severin" => "transporte",
      "Amazon-Marketplace" => "eletrônicos",
      "Home Sushi Home Tere" => "ifood",
      "Decolar Com 5/6" => "viagem",
      "Rcl*O Coronel" => "restaurante",
      "Pagamento de boleto efetuado - GVT" => "casa",
      "Transferência enviada pelo Pix - Ricardo Lopes da Silva - 057.194.793-09 - BCO SANTANDER (BRASIL) S.A. (0033) Agência: 4326 Conta: 1063877-1" =>
        "lazer",
      "Transferência enviada pelo Pix - Alexandre Marangoni Costa - 036.777.193-48 - BCO DO BRASIL S.A. (0001) Agência: 3178 Conta: 1244-0" =>
        "lazer",
      "Cbc Teresina Shopping" => "restaurante",
      "Free Mobile" => "viagem",
      "Iana Maiana Lustosa Ma" => "restaurante",
      "Engecopi" => "casa",
      "Frango Rustico" => "restaurante",
      "Transferência enviada pelo Pix - Elyssandra Souza Gramoza Vilarinho - 022.231.883-03 - MERCADO PAGO IP LTDA. (0323) Agência: 1 Conta: 8448830887-8" =>
        "lazer",
      "Compra no débito - Pao de Acucar 2382 Dom" => "supermercado",
      "O P Martins" => "restaurante",
      "Transferência recebida pelo Pix - ELNA M O NUNES SILVA TITO - 132.393.843-53 - BCO DO BRASIL S.A. (0001) Agência: 3178 Conta: 869195-9" =>
        "casa",
      "Www*Sympla42a35g" => "lazer",
      "Pag*Postoparaiso" => "transporte",
      "Transferência enviada pelo Pix - ELNA M O NUNES SILVA TITO - 132.393.843-53 - BCO DO BRASIL S.A. (0001) Agência: 3178 Conta: 869195-9" =>
        "casa",
      "Spe-Sociparques Chapa" => "viagem",
      "Pg *F & I Comercio" => "restaurante",
      "The Pug" => "restaurante",
      "Ebanx *Rentngcarz 2/4" => "viagem",
      "Clinica I L P" => "saúde",
      "Transferência enviada pelo Pix - Ester Ruth Da Silva Alves - 144.120.757-02 - PICPAY (0380) Agência: 1 Conta: 76972492-2" =>
        "casa",
      "Adega Santiago - A4rj" => "restaurante",
      "IOF de \"Cofiroute\"" => "viagem",
      "Mangata" => "restaurante",
      "Smiles Fidel*Bilhete" => "viagem",
      "Latam Site 3/3" => "viagem",
      "Pagamento de boleto efetuado - CLARO SP DDD 11" => "serviços",
      "Transferência enviada pelo Pix - G3 TELECOM - 13.133.062/0001-13 - BCO SANTANDER (BRASIL) S.A. (0033) Agência: 100 Conta: 13008066-5" =>
        "lazer",
      "Concessao Metroviaria" => "transporte",
      "Pagamento de fatura" => "cartao",
      "Transferência enviada pelo Pix - GABRIEL SILVA                     - 131.155.996-50 - BRB - BCO DE BRASILIA S.A. (0070) Agência: 355 Conta: 355044308-2" =>
        "viagem",
      "Transferência enviada pelo Pix - ERLON S C VIEIRA EIRELI - 29.227.781/0001-33 - CAIXA ECONOMICA FEDERAL (0104) Agência: 29 Conta: 3000000000006765-5" =>
        "imposto",
      "Posto Petroleo" => "transporte",
      "Holy Ramen" => "viagem",
      "Surf Ski Shop" => "viagem",
      "Transferência enviada pelo Pix - PREMIUM PESCADOS - 21.817.800/0001-70 - ITAÚ UNIBANCO S.A. (0341) Agência: 4826 Conta: 39003-3" =>
        "supermercado",
      "Via Palatto" => "restaurante",
      "Rcl*Restaurante Elmo" => "restaurante",
      "Smart Ingresse 1/2" => "lazer",
      "Esf la Rosiere" => "viagem",
      "Maciel e Assuncao" => "restaurante",
      "Gregus Grill" => "restaurante",
      "Compra no débito - Celer*O Coronel" => "restaurante",
      "Transferência enviada pelo Pix - Eduardo Costa Carvalho - 988.163.733-34 - BCO C6 S.A. (0336) Agência: 1 Conta: 6259496-6" =>
        "lazer",
      "Farm Village Mall" => "mariel",
      "99* Pop 04mai 22h36min" => "transporte",
      "Drogarias Globo" => "saúde",
      "Pinbank*Bar Devassa" => "restaurante",
      "Pag*Kitcasa 1/2" => "casa",
      "Latam Site 1/3" => "viagem",
      "Compra no débito - Pag*Danieldasilva" => "outros",
      "O Coronel" => "restaurante",
      "Urbano Pub" => "restaurante",
      "F N Mesquita Colares" => "restaurante",
      "Smart Center" => "eletrônicos",
      "Henry Morgan Lima Mat" => "restaurante",
      "Posto 2498 Teresina" => "transporte",
      "H Plus Administracao e" => "viagem",
      "Saque - Aer Brasilia I" => "viagem",
      "Transferência enviada pelo Pix - MH PATISSERIE - 34.130.197/0001-03 - NU PAGAMENTOS - IP (0260) Agência: 1 Conta: 43724036-6" =>
        "ifood",
      "Transferência recebida pelo Pix - RAMON FREITAS PESSOA - 039.662.423-54 - BCO DO BRASIL S.A. (0001) Agência: 1637 Conta: 124664-0" =>
        "supermercado",
      "Transferência enviada pelo Pix - Benito Mussolini de Araujo Bastos Neto - 015.077.203-35 - NU PAGAMENTOS - IP (0260) Agência: 1 Conta: 50745683-2" =>
        "serviços",
      "IOF de \"Free Mobile\"" => "viagem",
      "IOF de \"Laduree\"" => "viagem",
      "Lapatisserie Favorito" => "supermercado",
      "Posto Sao Raimundo" => "transporte",
      "Picpay**Bd1*Alexandrec" => "outros",
      "Smd Distri Dac" => "viagem",
      "Dr Chopp" => "restaurante",
      "IOF de \"Holy Ramen\"" => "viagem",
      "Laduree" => "restaurante",
      "Cravo e Canela" => "restaurante",
      "Nazareth Eco" => "viagem",
      "Campo Base Ecolodge" => "restaurante",
      "Arena Esportiva" => "lazer",
      "Pao de Acucar 2382 Dom" => "supermercado",
      "IOF de \"Smd Distri Dac\"" => "viagem",
      "Pao de Acucar-2382" => "supermercado",
      "Transferência enviada pelo Pix - ROTARY CLUB DE TERESINA - FATIMA - 21.126.827/0001-16 - BCO DO BRASIL S.A. (0001) Agência: 44 Conta: 120032-1" =>
        "outros",
      "Gol Transp A*Rndzsp013 2/5" => "viagem",
      "Olik" => "restaurante",
      "Transferência recebida pelo Pix - EZEQUIAS G COSTA FH - 330.640.837-91 - BCO DO BRASIL S.A. (0001) Agência: 3178 Conta: 75332-7" =>
        "outros",
      "Burger King Teresina S" => "restaurante",
      "Bahrzen Chapada" => "restaurante",
      "Latam Site" => "viagem",
      "Pag*Concretize" => "serviços",
      "Urbano Bar" => "restaurante",
      "Malagueta Bar e Rest" => "restaurante",
      "Transferência Recebida - MARIEL NUNES ARQUITETURA LTDA - 38.232.494/0001-02 - NU PAGAMENTOS - IP (0260) Agência: 1 Conta: 85305300-8" =>
        "mariel",
      "Transferência recebida pelo Pix - MARCOS ANDRE LIMA RAMOS - 618.312.553-91 - ITAÚ UNIBANCO S.A. (0341) Agência: 7962 Conta: 25350-1" =>
        "outros",
      "la Mangerie" => "restaurante",
      "Transferência enviada pelo Pix - Mariel Nunes de Sousa - 003.962.473-00 - BCO DO BRASIL S.A. (0001) Agência: 3178 Conta: 124767-0" =>
        "mariel",
      "Catedral Lanches" => "restaurante",
      "Transferência enviada pelo Pix - farlys do Amaral costa - 823.029.873-49 - NU PAGAMENTOS - IP (0260) Agência: 1 Conta: 18795745-0" =>
        "lazer",
      "Transferência enviada pelo Pix - 5 A SEC - 09.547.491/0001-60 - CAIXA ECONOMICA FEDERAL (0104) Agência: 855 Conta: 3000000000003455-3" =>
        "serviços",
      "Sr Gil Steak House" => "restaurante",
      "Ifood *Ifoodgorjeta" => "ifood",
      "Transferência recebida pelo Pix - ALEXANDRE MARANGONI COSTA - 036.777.193-48 - BCO DO BRASIL S.A. (0001) Agência: 3178 Conta: 1244-0" =>
        "recebido",
      "Transferência Recebida - Alexandre Marangoni Costa - 036.777.193-48 - XP Investimentos Corretora de Câmbio Títulos e Valores Mobiliários S.A. (0102) Agência: 3 Conta: 249876-4" =>
        "recebido",
      "Estacionamento Rio Pot" => "transporte",
      "Morgan Japanese Cuisin" => "restaurante",
      "Transferência enviada pelo Pix - Davidson Oliveira Lopes da Cunha - 116.255.097-07 - NU PAGAMENTOS - IP (0260) Agência: 1 Conta: 10739552-2" =>
        "lazer",
      "de Quinta Categoria" => "restaurante",
      "Acqio*Posto Amarracao" => "transporte",
      "Latam Site 1/4" => "viagem",
      "Diverticidade Eventos" => "lazer",
      "Riverside" => "casa",
      "Yan Ping" => "restaurante",
      "Total Mkt Fr" => "transporte",
      "IOF de \"Esf la Rosiere\"" => "viagem",
      "Drogaria Redepopular" => "saúde",
      "Cafe do Mar" => "restaurante",
      "Teresina Administrador" => "casa",
      "Kennedy Bebidas" => "supermercado",
      "Transferência enviada pelo Pix - Mariel Nunes de Sousa - 003.962.473-00 - NU PAGAMENTOS - IP (0260) Agência: 1 Conta: 77621649-2" =>
        "mariel",
      "Transferência enviada pelo Pix - GLEISON DA SILVA OLIVEIRA SALES - 064.857.093-20 - BCO DO BRASIL S.A. (0001) Agência: 5602 Conta: 55119-8" =>
        "casa",
      "Mp *Iningarestaur" => "restaurante",
      "Transferência enviada pelo Pix - ANDERSON VASCONCELOS DE MORAES - 990.743.703-49 - BCO DO BRASIL S.A. (0001) Agência: 3178 Conta: 108320-1" =>
        "restaurante",
      "Pagamento de boleto efetuado - G3 TELECOM EIRELI" => "lazer",
      "Ferreira Supermercados" => "supermercado",
      "Uber *Trip Help.Uber.C" => "transporte",
      "Marcelle Carvalho Gon" => "serviços",
      "Pagamento de boleto efetuado - GOV ESTADO BRAE" => "casa",
      "Pao Togo" => "restaurante",
      "Decolar Com 6/6" => "viagem",
      "Transferência enviada pelo Pix - Lucas Leony Barros - 061.632.303-45 - PAGSEGURO INTERNET IP S.A. (0290) Agência: 1 Conta: 9804318-5" =>
        "transporte",
      "Hotel Vendome" => "viagem",
      "Rustico" => "restaurante",
      "Transferência enviada pelo Pix - CONGELADOS DA SONIA LTDA - 36.157.576/0001-04 - ITAÚ UNIBANCO S.A. (0341) Agência: 307 Conta: 37689-7" =>
        "restaurante",
      "Pg *Jamesdelivery" => "supermercado",
      "Transferência enviada pelo Pix - LUCAS GUILLEN SILVEIRA - 060.422.347-14 - NU PAGAMENTOS - IP (0260) Agência: 1 Conta: 8847742-4" =>
        "lazer",
      "Casa do Saulo" => "restaurante",
      "Pousada Fazenda Sao Be" => "restaurante",
      "IOF de \"la Mangerie\"" => "viagem",
      "Mp *Ton" => "transporte",
      "Cofiroute" => "viagem",
      "Posto Lagoa" => "transporte",
      "Transferência enviada pelo Pix - CARLENE SOUSA BARROS - 035.053.743-77 - CAIXA ECONOMICA FEDERAL (0104) Agência: 3880 Conta: 1288000000956165397-0" =>
        "restaurante",
      "Terraco Bar e Happy Ho" => "restaurante",
      "San Blas Restaurante" => "restaurante",
      "Feira Leste" => "supermercado",
      "Transferência recebida pelo Pix - A COSTA ADVOGADOS ASS - 01.442.338/0001-66 - BCO DO BRASIL S.A. (0001) Agência: 3507 Conta: 33205-4" =>
        "lazer",
      "Transferência recebida pelo Pix - ANA ELISA MARANGONI COSTA - 606.823.457-68 - BCO BRADESCO S.A. (0237) Agência: 2120 Conta: 2106-7" =>
        "outros",
      "Transferência enviada pelo Pix - IVAN C LOPES - 135.567.917-65 - ITAÚ UNIBANCO S.A. (0341) Agência: 7035 Conta: 16463-6" =>
        "outros",
      "Meep *We Love" => "lazer",
      "IOF de \"Brioche Doree\"" => "viagem",
      "Latam Site 2/3" => "viagem",
      "Restaurante Fagulhas" => "restaurante",
      "Compra no débito - Oliveira Sousa Panific" => "restaurante",
      "Teresina Drive" => "restaurante",
      "Compra no débito - Tayse Ferreira da Sil" => "viagem",
      "Pag*Darlansilvados" => "restaurante",
      "IOF de \"Uber *Trip Help.Uber.C\"" => "viagem",
      "Estorno de IOF de compra internacional" => "viagem",
      "Centro Musical Riversi" => "lazer",
      "Transferência enviada pelo Pix - MERCADO DOS GRAOS - 29.801.666/0002-01 - CAIXA ECONOMICA FEDERAL (0104) Agência: 855 Conta: 3000000000008322-8" =>
        "supermercado",
      "Wandson Jorlan Henriq" => "outros",
      "Laide Borges" => "restaurante",
      "Transferência recebida pelo Pix - ITAU VALORES A DEVOLVER - 60.701.190/0001-04 - ITAÚ UNIBANCO S.A. (0341) Agência: 1063 Conta: 2680-9" =>
        "outros",
      "Saque - Drog Bellamares" => "lazer",
      "Tembici" => "lazer",
      "Gol Transp A*Rndzsp013 1/5" => "viagem"
    }
  end
end

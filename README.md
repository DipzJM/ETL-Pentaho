# Projeto de Data Warehouse: SnacksMart (Grupo Catchall)

## 📝 Visão Geral
Este repositório documenta a implementação do Data Warehouse (DW) da **SnacksMart**, uma empresa do grupo **Catchall Group**. 

O Catchall Group, que detém também a MediaFlix, está a levar a cabo uma estratégia de gestão baseada na consolidação de dados de vendas de todas as suas participadas (setor alimentar, distribuição e media) para obter uma visão de negócio integrada e transversal.

## 🏢 Sobre a SnacksMart
A SnacksMart é uma multinacional de distribuição generalista com uma operação de larga escala:

* **Presença Geográfica:** Lojas físicas na Europa, Estados Unidos, México e Canadá.
* **Canais de Venda:**
    * Lojas físicas tradicionais.
    * Distribuição porta-a-porta através de canais eletrónicos (**Mobile** e **Web**), lançados no final do ano passado.
* **Recursos Humanos:** Mais de 1000 colaboradores.
* **Modelo de Operação:** Ao contrário do retalho tradicional, a SnacksMart exige o **registo/identificação obrigatória** do cliente para acesso às lojas e plataformas digitais. Este modelo otimiza o processo de compra, entrega e pagamentos.

## 💻 Ecossistema Tecnológico
A infraestrutura de suporte à operação da SnacksMart é composta por dois sistemas principais que servem de fontes de dados para o DW:

### 1. ERP Moskatel
* **Função:** Sistema central de gestão e repositório principal de **dados mestre**.
* **Interoperabilidade:** Disponibiliza um conjunto de **WebServices** que permitem a sincronização de dados mestre com os restantes sistemas da organização.

### 2. Bakalhoa (Plataforma de E-commerce)
* **Função:** Gestão das operações de comércio eletrónico (vendas online).
* **Dados:** Gere autonomamente os dados mestre específicos da plataforma que não existam no sistema central.

## 🚀 Objetivos da Implementação
A implementação do DW da SnacksMart decorre em paralelo com a da MediaFlix, focando-se em:

1.  **Consolidação de Vendas:** Unificar os dados provenientes do ERP e da plataforma de e-commerce.
2.  **Visão 360º do Cliente:** Aproveitar o sistema de identificação obrigatória para traçar o perfil de consumo multicanal (físico vs. digital).
3.  **Padronização de Dados Mestre:** Garantir a integridade da informação através da interligação via WebServices entre o Moskatel e o Bakalhoa.

--Scripts referentes à lista de exercícios Tesseract (Breakeven de Andreza)

--1)Quais organizações temos dentro do tesseract? Resposta
select distinct organization from digital_dataops.dim_affiliation;

/*1) Resposta
    mundipagg
    pagarme
    stone
    stone_and_mundipagg
*/

--2)Quantas chaves diferentes temos no tesseract em chave de afiliação (affiliation_key)?
select count(distinct affiliation_key) as qtde_affiliation_key
from digital_dataops.dim_affiliation;

/*2) Resposta
  4.482.729
*/


--3)Quantas chaves de afiliação (internal_affiliation_id) diferente temos no tesseract?

select count(distinct internal_affiliation_id ) as qtde_internal_affiliation_id
from digital_dataops.dim_affiliation;

/*3) Resposta
1.670.912
*/
--4)Quantos reais foram transacionados no mes corrente agrupando os dados por organização (pagarme, stone, mundi)?

select organization, round(sum(tpv) :: numeric / 100, 2) as tpv_reais
from digital_dataops.fact_tpv
  inner join digital_dataops.dim_date using (date_key)
  inner join digital_dataops.dim_affiliation using (affiliation_key)
where date_trunc('month', dimension_date) = date_trunc('month', current_timestamp at time zone 'brt')
and date_trunc('year', dimension_date) = date_trunc('year', current_timestamp at time zone 'brt')
group by organization;

/*4) Resposta
    organization            tpv_reais
    stone,                3041598539.42
    mundipagg,            2633709368.94
    pagarme,              2207252858.83
    stone_and_mundipagg,  1705329570.90

*/

--5)Quantos reais foram transacionados no primeiro trimestre do ano de 2020 agrupando os dados por encarteiramento?

select channel encarteiramento,
       sum(f_tpv.tpv) as total
from digital_dataops.fact_tpv f_tpv
inner join digital_dataops.dim_date  using (date_key)
inner join digital_dataops.dim_affiliation  using (affiliation_key)
where date_trunc('month', dimension_date) between '2020-01-01' and '2020-03-31'
group by encarteiramento;
/*5) Resposta
    encarteiramento            total
    STONE MAIS,             4084350715
    INT PARTNERSHIPS,       1384013300857
    DIGITAL,                1097736584693
    POLOS,                  9016800566
*/

--6)Quantos reais foram estornados em 2020 agrupando os valores por mes e colocando em ordem crescente?

select month, sum(tpv_refund) :: numeric/100 as tpv_refund_month
from digital_dataops.fact_tpv
left join digital_dataops.dim_date using(date_key)
where year = 2020
group by month
order by month asc;

/*6) Resposta
    month       tpv_refund_month
    1,          157456423.6900
    2,          132146730.2100
    3,          212068766.8200
    4,          144937970.6200
    5,          137149057.0700
    6,          145984787.7300
    7,          153917096.2400
    8,          139512357.2200
    9,          138458636.0700
    10,         126718590.0300
    11,         140619770.7600
    12,         162061650.6900
*/

--7)Quantos reais foram estornados em 2019 agrupando os valores por mes e colocando em ordem decrescente?

select month, sum(tpv_refund) :: numeric/100 as tpv_refund_month
from digital_dataops.fact_tpv
left join digital_dataops.dim_date using(date_key)
where year = 2019
group by month
order by month desc;

/*7) Resposta
    month       tpv_refund_month
    12,         169435838.1800
    11,         123005631.7400
    10,         107563032.7400
    9,          90910519.3200
    8,          88660403.4400
    7,          85749637.5900
    6,          66361898.4600
    5,          74928279.7100
    4,          70423969.1800
    3,          70022795.5300
    2,          83027067.1800
    1,          96422589.6900
*/

--8)Quanto de chargeback o produto Link de pagamento ja sofreu? Resposta

select round(sum(tpv_chargeback) :: numeric / 100, 2) as tpv_chargeback_reais
from digital_dataops.fact_tpv
  inner join digital_dataops.dim_service using (service_key)
where link_indicator = 'Link';

/*8) Resposta
    tpv_chargeback_reais
    13443673.24
*/

--9)Quanto de chargeback os produtos Split, Link de pagamento e Subscription ja sofreram? Resposta

select round(sum(case when link_indicator = 'Link' then tpv_chargeback end) :: numeric / 100, 2) as tpv_chargeback_reais_link,
       round(sum(case when subscription_indicator = 'Subscription' then tpv_chargeback end) :: numeric / 100, 2) as tpv_chargeback_reais_subs,
       round(sum(case when split_indicator = 'Split' then tpv_chargeback end) :: numeric / 100, 2) as tpv_chargeback_reais_split
from digital_dataops.fact_tpv
inner join digital_dataops.dim_service using (service_key)

/*9) Resposta
    tpv_chargeback_reais_link   tpv_chargeback_reais_subs   tpv_chargeback_reais_split
    13443673.24,                10410463.73,                108366373.30
*/

--10)Qual sub_channel trouxe mais TPV no primeiro trimestre de 2020?

select sub_channel,
  round(sum(tpv) :: numeric / 100, 2) as tpv_reais
from digital_dataops.fact_tpv
  inner join digital_dataops.dim_date using (date_key)
  inner join digital_dataops.dim_affiliation using (affiliation_key)
where
  date_trunc('month', dimension_date) between '2020-01-01' and '2020-03-31'
group by sub_channel
order by tpv_reais desc
limit 1;

/*10) Resposta
  sub_channel       tpv_reais
  SUBADQUIRENTES,   12594642450.14
*/

--11)Qual o id dos clientes Pagar.me que transacionaram psp no mês corrente, considerando apenas cartão de crédito.

select distinct internal_affiliation_id
from digital_dataops.fact_tpv as psp_tpv
  inner join digital_dataops.dim_service using (service_key)
  inner join digital_dataops.dim_affiliation as psp_aff using (affiliation_key)
  inner join digital_dataops.dim_payment using (payment_key)
  inner join digital_dataops.dim_date using (date_key)
where product_name = 'psp'
  and payment_method = 'credit_card'
  and organization = 'pagarme'
  and date_trunc('month', dimension_date) = date_trunc('month', current_timestamp at time zone 'brt');

/*11) Resposta
  Listagem.

*/

--12)Qual a receita de MDR agrupado por mes e por adquirente em 2020?

select date_trunc('month', dimension_date) as month,
  source_type as adquirente,
  round(sum(revenue_amount) :: numeric / 100, 2) as mdr_revenue
from digital_dataops.fact_revenue
  inner join digital_dataops.dim_date using (date_key)
  inner join digital_dataops.dim_source using (source_key)
where source_name = 'mdr'
  and year = 2020
group by date_trunc('month', dimension_date), source_type
order by date_trunc('month', dimension_date), source_type;

/*12) Resposta

  Listagem;

*/
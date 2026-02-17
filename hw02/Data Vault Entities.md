# Хабы 
Содержат только уникальный бизнес-ключ, суррогатный ключ, дату загрузки и источник.

- HUB_USER: BK — user_external_id.
- HUB_ADDRESS: BK — address_external_id
- HUB_ORDER: BK — order_external_id.
- HUB_PRODUCT: BK — product_sku.
- HUB_SHIPMENT: BK — shipment_external_id.
- HUB_WAREHOUSE: BK — warehouse_code
- HUB_PICKUP_POINT: BK — pickup_point_code.

### HUB_USERS
|**Атрибут**|**Тип данных**|**Описание**|
|---|---|---|
|**USER_ID**|SERIAL / BIGINT|**Primary Key**: Суррогатный ключ хранилища.|
|**USER_EXTERNAL_ID**|UUID|**Business Key**: Уникальный идентификатор из системы-источника.|
|**LOAD_DATE**|TIMESTAMP|Техническое поле: время загрузки записи в Hub.|
|**RECORD_SOURCE**|VARCHAR(100)|Техническое поле: источник данных (например, 'CRM_SYSTEM').|

### HUB_ORDER 
|**Атрибут**|**Тип данных**|**Описание**|
|---|---|---|
|**ORDER_ID**|SERIAL / BIGINT|**Primary Key**: Суррогатный ключ хранилища.|
|**ORDER_EXTERNAL_ID**|UUID|**Business Key**: Уникальный ID заказа.|
|**ORDER_NUMBER**|VARCHAR(100)|Дополнительный Business Key (номер заказа).|
|**LOAD_DATE**|TIMESTAMP|Техническое поле: дата загрузки.|
|**RECORD_SOURCE**|VARCHAR(100)|Техническое поле: источник данных.|

### HUB_PRODUCT
| **Атрибут**       | **Тип данных**  | **Описание**                       |
| ----------------- | --------------- | ---------------------------------- |
| **PRODUCT_ID**    | SERIAL / BIGINT | **Primary Key**: Суррогатный ключ. |
| **PRODUCT_SKU**   | VARCHAR(100)    | **Business Key**: Артикул товара.  |
| **LOAD_DATE**     | TIMESTAMP       | Техническое поле.                  |
| **RECORD_SOURCE** | VARCHAR(100)    | Техническое поле.                  |

### HUB_SHIPMENT

|**Атрибут**|**Тип данных**|**Описание**|
|---|---|---|
|**SHIPMENT_ID**|SERIAL / BIGINT|**Primary Key**: Суррогатный ключ.|
|**SHIPMENT_EXTERNAL_ID**|UUID|**Business Key**: Внешний ID отправления.|
|**TRACKING_NUMBER**|VARCHAR(100)|Дополнительный Business Key: трек-номер.|
|**LOAD_DATE**|TIMESTAMP|Техническое поле.|
|**RECORD_SOURCE**|VARCHAR(100)|Техническое поле.|

### HUB_ADDRESS

|**Атрибут**|**Тип данных**|**Описание**|
|---|---|---|
|**ADDRESS_ID**|SERIAL / BIGINT|**Primary Key**: Суррогатный ключ.|
|**ADDRESS_EXTERNAL_ID**|UUID|**Business Key**: Уникальный ID адреса.|
|**LOAD_DATE**|TIMESTAMP|Техническое поле.|
|**RECORD_SOURCE**|VARCHAR(100)|Техническое поле.|

### HUB_WAREHOUSE
|**Атрибут**|**Тип данных**|**Описание**|
|---|---|---|
|**WAREHOUSE_ID**|SERIAL / BIGINT|**Primary Key**: Суррогатный ключ.|
|**WAREHOUSE_CODE**|VARCHAR(50)|**Business Key**: Уникальный код склада.|
|**LOAD_DATE**|TIMESTAMP|Техническое поле.|
|**RECORD_SOURCE**|VARCHAR(100)|Техническое поле.|

### HUB_PICKUP_POINT
|**Атрибут**|**Тип данных**|**Описание**|
|---|---|---|
|**PICKUP_POINT_ID**|SERIAL / BIGINT|**Primary Key**: Суррогатный ключ.|
|**PICKUP_POINT_CODE**|VARCHAR(50)|**Business Key**: Уникальный код ПВЗ.|
|**LOAD_DATE**|TIMESTAMP|Техническое поле.|
|**RECORD_SOURCE**|VARCHAR(100)|Техническое поле.|


---

# Линки
Линки фиксируют уникальные комбинации связей между бизнес-ключами. Включает: суррогатный ключ, ключи хабов, дата загрузки, код источника данных

- LNK_USER_ADDRESS: Связывает пользователя и его адреса (user_external_id + address_external_id).

- LNK_ORDER_USER: Связывает заказ с клиентом (order_external_id + user_external_id).

- LNK_ORDER_ADDRESS: Связь заказа с адресом доставки (order_external_id + delivery_address_external_id).

- LNK_ORDER_ITEM: Связь конкретной позиции в чеке (order_external_id + product_sku).

- LNK_SHIPMENT_ORDER: Привязка отгрузки к заказу (shipment_external_id + order_external_id).

- LNK_SHIPMENT_ADDRESS: Связь доставки с конечным адресом (shipment_external_id + destination_address_external_id).

- LNK_SHIPMENT_WAREHOUSE: Связь отгрузки со складом отправления (shipment_external_id + origin_warehouse_code).
- LNK_SHIPMENT_PICKUP_POINT: Связь отгрузки с пунктом выдачи (shipment_external_id + destination_pickup_point_code).



### LNK_ORDER_USER
|**Атрибут**|**Тип данных**|**Описание**|
|---|---|---|
|**LNK_ORDER_USER_ID**|BIGINT|**Primary Key**: Суррогатный ключ связи.|
|**ORDER_ID**|BIGINT|**Foreign Key**: Ссылка на `HUB_ORDER.ORDER_ID`.|
|**USER_ID**|BIGINT|**Foreign Key**: Ссылка на `HUB_USER.USER_ID`.|
|**LOAD_DATE**|TIMESTAMP|Время появления связи в системе.|
|**RECORD_SOURCE**|VARCHAR(100)|Источник данных.|

### LNK_ORDER_ITEM
|**Атрибут**|**Тип данных**|**Описание**|
|---|---|---|
|**LNK_ORDER_ITEM_ID**|BIGINT|**Primary Key**: Суррогатный ключ позиции заказа.|
|**ORDER_ID**|BIGINT|**Foreign Key**: Ссылка на `HUB_ORDER.ORDER_ID`.|
|**PRODUCT_ID**|BIGINT|**Foreign Key**: Ссылка на `HUB_PRODUCT.PRODUCT_ID`.|
|**LOAD_DATE**|TIMESTAMP|Дата загрузки.|
|**RECORD_SOURCE**|VARCHAR(100)|Источник.|

### LNK_SHIPMENT_ORDER
|**Атрибут**|**Тип данных**|**Описание**|
|---|---|---|
|**LNK_SHIPMENT_ORDER_ID**|BIGINT|**Primary Key**: Суррогатный ключ связи.|
|**SHIPMENT_ID**|BIGINT|**Foreign Key**: Ссылка на `HUB_SHIPMENT.SHIPMENT_ID`.|
|**ORDER_ID**|BIGINT|**Foreign Key**: Ссылка на `HUB_ORDER.ORDER_ID`.|
|**LOAD_DATE**|TIMESTAMP|Дата загрузки.|
|**RECORD_SOURCE**|VARCHAR(100)|Источник.|
### LNK_USER_ADDRESS
| **Атрибут**             | **Тип данных** | **Описание**                                         |
| ----------------------- | -------------- | ---------------------------------------------------- |
| **LNK_USER_ADDRESS_ID** | BIGINT         | **Primary Key**: Суррогатный ключ.                   |
| **USER_ID**             | BIGINT         | **Foreign Key**: Ссылка на `HUB_USER.USER_ID`.       |
| **ADDRESS_ID**          | BIGINT         | **Foreign Key**: Ссылка на `HUB_ADDRESS.ADDRESS_ID`. |
| **LOAD_DATE**           | TIMESTAMP      | Дата загрузки.                                       |
| **RECORD_SOURCE**       | VARCHAR(100)   | Источник.                                            |

### LNK_SHIPMENT_MOVEMENT
| **Атрибут**           | **Тип данных** | **Описание**                               |
| --------------------- | -------------- | ------------------------------------------ |
| **LNK_MOVEMENT_ID**   | BIGINT         | **Primary Key**: Суррогатный ключ события. |
| **SHIPMENT_ID**       | BIGINT         | **Foreign Key**: Ссылка на `HUB_SHIPMENT`. |
| **MOVEMENT_TYPE**     | VARCHAR(50)    | Тип перемещения.                           |
| **LOCATION_CODE**     | VARCHAR(50)    | Код локации (склада или ПВЗ).              |
| **MOVEMENT_DATETIME** | TIMESTAMP      | Время события.                             |
| **LATITUDE**          | DECIMAL        | Координата широты.                         |
| **LONGITUDE**         | DECIMAL        | Координата долготы.                        |
| **LOAD_DATE**         | TIMESTAMP      | Время загрузки в DWH.                      |
| **RECORD_SOURCE**     | VARCHAR(100)   | Источник.                                  |

### LNK_ORDER_ADDRESS
|**Атрибут**|**Тип данных**|**Описание**|
|---|---|---|
|**LNK_ORDER_ADDRESS_ID**|BIGINT|**Primary Key**: Суррогатный ключ связи.|
|**ORDER_ID**|BIGINT|**Foreign Key**: Ссылка на `HUB_ORDER.ORDER_ID`.|
|**ADDRESS_ID**|BIGINT|**Foreign Key**: Ссылка на `HUB_ADDRESS.ADDRESS_ID`.|
|**LOAD_DATE**|TIMESTAMP|Техническое поле: время загрузки.|
|**RECORD_SOURCE**|VARCHAR(100)|Источник данных.|

### LNK_SHIPMENT_WAREHOUSE
|**Атрибут**|**Тип данных**|**Описание**|
|---|---|---|
|**LNK_SHIPMENT_WH_ID**|BIGINT|**Primary Key**: Суррогатный ключ связи.|
|**SHIPMENT_ID**|BIGINT|**Foreign Key**: Ссылка на `HUB_SHIPMENT.SHIPMENT_ID`.|
|**WAREHOUSE_ID**|BIGINT|**Foreign Key**: Ссылка на `HUB_WAREHOUSE.WAREHOUSE_ID`.|
|**LOAD_DATE**|TIMESTAMP|Время появления связи.|
|**RECORD_SOURCE**|VARCHAR(100)|Источник (система логистики).|

### LNK_SHIPMENT_PICKUP_POINT
| **Атрибут**            | **Тип данных** | **Описание**                                                   |
| ---------------------- | -------------- | -------------------------------------------------------------- |
| **LNK_SHIPMENT_PP_ID** | BIGINT         | **Primary Key**: Суррогатный ключ связи.                       |
| **SHIPMENT_ID**        | BIGINT         | **Foreign Key**: Ссылка на `HUB_SHIPMENT.SHIPMENT_ID`.         |
| **PICKUP_POINT_ID**    | BIGINT         | **Foreign Key**: Ссылка на `HUB_PICKUP_POINT.PICKUP_POINT_ID`. |
| **LOAD_DATE**          | TIMESTAMP      | Дата загрузки.                                                 |
| **RECORD_SOURCE**      | VARCHAR(100)   | Источник данных.                                               |



---
# Сателлиты
Хранят: PK сателлита - это PK хаба или линка,даты действия записи (SCD Type 2), дата загрузки, код источника данных.

- SAT_USER_DETAILS: Данные профиля (email, имя, телефон, дата рождения).

- SAT_USER_STATUS: История статусов пользователя и причины изменений.

- SAT_ADDRESS_DETAILS: Географические данные (страна, город, улица, индекс).

- SAT_ORDER_DETAILS: Параметры заказа (сумма, валюта, способ оплаты).

- SAT_ORDER_STATUS: История жизненного цикла заказа.

- SAT_ORDER_ITEM_DETAILS: Контекст продажи (количество, цена на момент заказа, снэпшоты названия и категории товара).

- SAT_PRODUCT_DETAILS: Характеристики товара (название, бренд, цена, габариты).

- SAT_SHIPMENT_DETAILS: Параметры посылки (трек-номер, вес, объем, планируемые даты).

- SAT_SHIPMENT_STATUS: Динамика изменения статусов доставки.

- SAT_SHIPMENT_MOVEMENT: История перемещений (координаты, локации, операторы).

- SAT_WAREHOUSE_DETAILS: Информация о складе (название, тип, вместимость, контакты).

- SAT_PICKUP_POINT_DETAILS: Информация о ПВЗ (название, тип, партнер, часы работы).



### SAT_USER_DETAILS 
|**Атрибут**|**Тип данных**|**Описание**|
|---|---|---|
|**USER_ID**|BIGINT|**FK**: Ссылка на `HUB_USER.USER_ID`.|
|**LOAD_DATE**|TIMESTAMP|**PK**: Время фиксации версии данных.|
|**FIRST_NAME**|VARCHAR(100)|Имя пользователя.|
|**LAST_NAME**|VARCHAR(100)|Фамилия.|
|**EMAIL**|VARCHAR(255)|Электронная почта.|
|**PHONE**|VARCHAR(50)|Номер телефона.|
|**RECORD_SOURCE**|VARCHAR(100)|Источник записи.|

### SAT_USER_STATUS
| **Атрибут**       | **Тип данных** | **Описание**                                           |
| ----------------- | -------------- | ------------------------------------------------------ |
| **USER_ID**       | BIGINT         | **FK**: Ссылка на `HUB_USER.USER_ID`.                  |
| **LOAD_DATE**     | TIMESTAMP      | **PK**: Время фиксации изменения статуса.              |
| **OLD_STATUS**    | VARCHAR(50)    | Предыдущий статус пользователя.                        |
| **NEW_STATUS**    | VARCHAR(50)    | Новый установленный статус.                            |
| **CHANGE_REASON** | VARCHAR(255)   | Причина изменения (комментарий системы или оператора). |
| **RECORD_SOURCE** | VARCHAR(100)   | Источник записи.                                       |

### SAT_ORDER_DETAILS
|**Атрибут**|**Тип данных**|**Описание**|
|---|---|---|
|**ORDER_ID**|BIGINT|**FK**: Ссылка на `HUB_ORDER.ORDER_ID`.|
|**LOAD_DATE**|TIMESTAMP|**PK**: Время загрузки.|
|**TOTAL_AMOUNT**|DECIMAL|Полная сумма заказа.|
|**CURRENCY**|VARCHAR(3)|Валюта заказа.|
|**PAYMENT_METHOD**|VARCHAR(50)|Способ оплаты.|
|**STATUS**|VARCHAR(50)|Текущий статус заказа.|
|**RECORD_SOURCE**|VARCHAR(100)|Источник.|

### SAT_ORDER_STATUS_HISTORY
| **Атрибут**       | **Тип данных** | **Описание**                                 |
| ----------------- | -------------- | -------------------------------------------- |
| **ORDER_ID**      | BIGINT         | **FK**: Ссылка на `HUB_ORDER.ORDER_ID`.      |
| **LOAD_DATE**     | TIMESTAMP      | **PK**: Время регистрации события.           |
| **NEW_STATUS**    | VARCHAR(50)    | Статус, в который перешел заказ.             |
| **CHANGE_REASON** | VARCHAR(255)   | Причина перехода.                            |
| **NOTES**         | TEXT           | Дополнительные технические заметки или логи. |
| **RECORD_SOURCE** | VARCHAR(100)   | Источник данных.                             |

### SAT_ORDER_ITEM_DETAILS
|**Атрибут**|**Тип данных**|**Описание**|
|---|---|---|
|**LNK_ORDER_ITEM_ID**|BIGINT|**FK**: Ссылка на `LNK_ORDER_ITEM_ID`.|
|**LOAD_DATE**|TIMESTAMP|**PK**: Время загрузки.|
|**QUANTITY**|INTEGER|Количество купленного товара.|
|**UNIT_PRICE**|DECIMAL|Цена за единицу на момент покупки.|
|**PRODUCT_NAME_SNAP**|VARCHAR(255)|Снэпшот названия товара из `ORDER_ITEMS`.|

### SAT_PRODUCT_DETAILS
| **Атрибут**      | **Тип данных** | **Описание**                                |
| ---------------- | -------------- | ------------------------------------------- |
| **PRODUCT_ID**   | BIGINT         | **FK**: Ссылка на `HUB_PRODUCT.PRODUCT_ID`. |
| **LOAD_DATE**    | TIMESTAMP      | **PK**: Время загрузки версии.              |
| **PRODUCT_NAME** | VARCHAR(255)   | Актуальное название в каталоге.             |
| **CATEGORY**     | VARCHAR(100)   | Категория товара.                           |
| **BRAND**        | VARCHAR(100)   | Бренд.                                      |
| **PRICE**        | DECIMAL        | Текущая цена в каталоге.                    |

### SAT_SHIPMENT_DETAILS
|**Атрибут**|**Тип данных**|**Описание**|
|---|---|---|
|**SHIPMENT_ID**|BIGINT|**FK**: Ссылка на `HUB_SHIPMENT.SHIPMENT_ID`.|
|**LOAD_DATE**|TIMESTAMP|**PK**: Время загрузки.|
|**STATUS**|VARCHAR(50)|Статус посылки.|
|**WEIGHT_GRAMS**|INTEGER|Вес отправления.|
|**EST_DELIVERY**|TIMESTAMP|Планируемая дата доставки.|
|**RECIPIENT_NAME**|VARCHAR(255)|Имя получателя.|
### SAT_ADDRESS_DETAILS
|**Атрибут**|**Тип данных**|**Описание**|
|---|---|---|
|**ADDRESS_ID**|BIGINT|**FK**: Ссылка на `HUB_ADDRESS`.|
|**LOAD_DATE**|TIMESTAMP|**PK**: Время загрузки.|
|**COUNTRY**|VARCHAR(100)|Страна.|
|**CITY**|VARCHAR(100)|Город.|
|**STREET_ADDRESS**|VARCHAR(255)|Улица и дом.|
|**POSTAL_CODE**|VARCHAR(20)|Почтовый индекс.|

### SAT_WAREHOUSE_DETAILS
|**Атрибут**|**Тип данных**|**Описание**|
|---|---|---|
|**WAREHOUSE_ID**|BIGINT|**FK**: Ссылка на `HUB_WAREHOUSE.WAREHOUSE_ID`.|
|**LOAD_DATE**|TIMESTAMP|**PK**: Время загрузки версии данных.|
|**WAREHOUSE_NAME**|VARCHAR(100)|Наименование склада.|
|**MAX_CAPACITY**|DECIMAL(15,2)|Максимальная вместимость в кубометрах.|
|**CONTACT_PHONE**|VARCHAR(50)|Телефон для связи.|
|**RECORD_SOURCE**|VARCHAR(100)|Источник записи.|
### SAT_PICKUP_POINT_DETAILS
|**Атрибут**|**Тип данных**|**Описание**|
|---|---|---|
|**PICKUP_POINT_ID**|BIGINT|**FK**: Ссылка на `HUB_PICKUP_POINT.PICKUP_POINT_ID`.|
|**LOAD_DATE**|TIMESTAMP|**PK**: Время фиксации версии.|
|**PICKUP_POINT_NAME**|VARCHAR(100)|Название ПВЗ.|
|**PARTNER_NAME**|VARCHAR(100)|Наименование партнера (например, "Ozon", "Boxberry").|
|**OPERATING_HOURS**|VARCHAR(255)|Режим работы.|
|**RECORD_SOURCE**|VARCHAR(100)|Источник данных.|

### SAT_PRODUCT_LOGISTICS
| **Атрибут**       | **Тип данных** | **Описание**                                |
| ----------------- | -------------- | ------------------------------------------- |
| **PRODUCT_ID**    | BIGINT         | **FK**: Ссылка на `HUB_PRODUCT.PRODUCT_ID`. |
| **LOAD_DATE**     | TIMESTAMP      | **PK**: Время загрузки.                     |
| **WEIGHT_GRAMS**  | INTEGER        | Вес товара в граммах.                       |
| **DIM_LENGTH_CM** | DECIMAL(10,2)  | Длина в см.                                 |
| **DIM_WIDTH_CM**  | DECIMAL(10,2)  | Ширина в см.                                |
| **DIM_HEIGHT_CM** | DECIMAL(10,2)  | Высота в см.                                |
| **RECORD_SOURCE** | VARCHAR(100)   | Источник данных.                            |

# Orders Analysis

## Data Cleaning and transformation using Pandas

### 1. Download data from Kaggle API


```python
!pip install -q kaggle zipfile36 pymysql
```


```python
# import libraries
import kaggle
import zipfile
import pandas as pd
from sqlalchemy import create_engine
```


```python
# Download dataset from kaggle
!kaggle datasets download ankitbansal06/retail-orders -f orders.csv
```

    Dataset URL: https://www.kaggle.com/datasets/ankitbansal06/retail-orders
    License(s): CC0-1.0
    
```python
# Extract file from zip file
zip_ref = zipfile.ZipFile('orders.csv.zip')
zip_ref.extractall() 
zip_ref.close()
```

### 2. Read the data as Pandas dataframe/ handle null values/ rename columns


```python
# Read in the data
df = pd.read_csv("orders.csv")
df.head()
```

<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Order Id</th>
      <th>Order Date</th>
      <th>Ship Mode</th>
      <th>Segment</th>
      <th>Country</th>
      <th>City</th>
      <th>State</th>
      <th>Postal Code</th>
      <th>Region</th>
      <th>Category</th>
      <th>Sub Category</th>
      <th>Product Id</th>
      <th>cost price</th>
      <th>List Price</th>
      <th>Quantity</th>
      <th>Discount Percent</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1</td>
      <td>2023-03-01</td>
      <td>Second Class</td>
      <td>Consumer</td>
      <td>United States</td>
      <td>Henderson</td>
      <td>Kentucky</td>
      <td>42420</td>
      <td>South</td>
      <td>Furniture</td>
      <td>Bookcases</td>
      <td>FUR-BO-10001798</td>
      <td>240</td>
      <td>260</td>
      <td>2</td>
      <td>2</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2</td>
      <td>2023-08-15</td>
      <td>Second Class</td>
      <td>Consumer</td>
      <td>United States</td>
      <td>Henderson</td>
      <td>Kentucky</td>
      <td>42420</td>
      <td>South</td>
      <td>Furniture</td>
      <td>Chairs</td>
      <td>FUR-CH-10000454</td>
      <td>600</td>
      <td>730</td>
      <td>3</td>
      <td>3</td>
    </tr>
    <tr>
      <th>2</th>
      <td>3</td>
      <td>2023-01-10</td>
      <td>Second Class</td>
      <td>Corporate</td>
      <td>United States</td>
      <td>Los Angeles</td>
      <td>California</td>
      <td>90036</td>
      <td>West</td>
      <td>Office Supplies</td>
      <td>Labels</td>
      <td>OFF-LA-10000240</td>
      <td>10</td>
      <td>10</td>
      <td>2</td>
      <td>5</td>
    </tr>
    <tr>
      <th>3</th>
      <td>4</td>
      <td>2022-06-18</td>
      <td>Standard Class</td>
      <td>Consumer</td>
      <td>United States</td>
      <td>Fort Lauderdale</td>
      <td>Florida</td>
      <td>33311</td>
      <td>South</td>
      <td>Furniture</td>
      <td>Tables</td>
      <td>FUR-TA-10000577</td>
      <td>780</td>
      <td>960</td>
      <td>5</td>
      <td>2</td>
    </tr>
    <tr>
      <th>4</th>
      <td>5</td>
      <td>2022-07-13</td>
      <td>Standard Class</td>
      <td>Consumer</td>
      <td>United States</td>
      <td>Fort Lauderdale</td>
      <td>Florida</td>
      <td>33311</td>
      <td>South</td>
      <td>Office Supplies</td>
      <td>Storage</td>
      <td>OFF-ST-10000760</td>
      <td>20</td>
      <td>20</td>
      <td>2</td>
      <td>5</td>
    </tr>
  </tbody>
</table>
</div>




```python
# Check null values
df.isnull().sum()
```




    Order Id            0
    Order Date          0
    Ship Mode           1
    Segment             0
    Country             0
    City                0
    State               0
    Postal Code         0
    Region              0
    Category            0
    Sub Category        0
    Product Id          0
    cost price          0
    List Price          0
    Quantity            0
    Discount Percent    0
    dtype: int64




```python
# There is one null value in `Ship Mode` column, let's check unique values in the column
df["Ship Mode"].unique()
```




    array(['Second Class', 'Standard Class', 'Not Available', 'unknown',
           'First Class', nan, 'Same Day'], dtype=object)



There are `Not Available` and `unknown` values in the `Ship Mode` column which can be classified as null values.


```python
# Read in the data and handle null values
df = pd.read_csv("orders.csv", na_values=["Not Available", "unknown"])
df["Ship Mode"].unique()
```




    array(['Second Class', 'Standard Class', nan, 'First Class', 'Same Day'],
          dtype=object)




```python
# Rename columns -> lower case and replace space with underscore
df.columns = df.columns.str.lower().str.replace(" ", "_")
df.head(3)
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>order_id</th>
      <th>order_date</th>
      <th>ship_mode</th>
      <th>segment</th>
      <th>country</th>
      <th>city</th>
      <th>state</th>
      <th>postal_code</th>
      <th>region</th>
      <th>category</th>
      <th>sub_category</th>
      <th>product_id</th>
      <th>cost_price</th>
      <th>list_price</th>
      <th>quantity</th>
      <th>discount_percent</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1</td>
      <td>2023-03-01</td>
      <td>Second Class</td>
      <td>Consumer</td>
      <td>United States</td>
      <td>Henderson</td>
      <td>Kentucky</td>
      <td>42420</td>
      <td>South</td>
      <td>Furniture</td>
      <td>Bookcases</td>
      <td>FUR-BO-10001798</td>
      <td>240</td>
      <td>260</td>
      <td>2</td>
      <td>2</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2</td>
      <td>2023-08-15</td>
      <td>Second Class</td>
      <td>Consumer</td>
      <td>United States</td>
      <td>Henderson</td>
      <td>Kentucky</td>
      <td>42420</td>
      <td>South</td>
      <td>Furniture</td>
      <td>Chairs</td>
      <td>FUR-CH-10000454</td>
      <td>600</td>
      <td>730</td>
      <td>3</td>
      <td>3</td>
    </tr>
    <tr>
      <th>2</th>
      <td>3</td>
      <td>2023-01-10</td>
      <td>Second Class</td>
      <td>Corporate</td>
      <td>United States</td>
      <td>Los Angeles</td>
      <td>California</td>
      <td>90036</td>
      <td>West</td>
      <td>Office Supplies</td>
      <td>Labels</td>
      <td>OFF-LA-10000240</td>
      <td>10</td>
      <td>10</td>
      <td>2</td>
      <td>5</td>
    </tr>
  </tbody>
</table>
</div>



### 3. Data Transformation - Feature Engineering
- Derive new columns `discount`, `sale_price` & `profit`
- Convert `order_date` from object data type to datetime
- Drop cost `cost_price`, `list_price` & `discount_percent` columns


```python
# Create new columns `discount`, `sale_price` & `profit`
df["discount"] = df["list_price"] * df["discount_percent"] * 0.01
df["sale_price"] = df["list_price"] - df["discount"]
df["profit"] = df["sale_price"] - df["cost_price"]
df.head(3)
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>order_id</th>
      <th>order_date</th>
      <th>ship_mode</th>
      <th>segment</th>
      <th>country</th>
      <th>city</th>
      <th>state</th>
      <th>postal_code</th>
      <th>region</th>
      <th>category</th>
      <th>sub_category</th>
      <th>product_id</th>
      <th>cost_price</th>
      <th>list_price</th>
      <th>quantity</th>
      <th>discount_percent</th>
      <th>discount</th>
      <th>sale_price</th>
      <th>profit</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1</td>
      <td>2023-03-01</td>
      <td>Second Class</td>
      <td>Consumer</td>
      <td>United States</td>
      <td>Henderson</td>
      <td>Kentucky</td>
      <td>42420</td>
      <td>South</td>
      <td>Furniture</td>
      <td>Bookcases</td>
      <td>FUR-BO-10001798</td>
      <td>240</td>
      <td>260</td>
      <td>2</td>
      <td>2</td>
      <td>5.2</td>
      <td>254.8</td>
      <td>14.8</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2</td>
      <td>2023-08-15</td>
      <td>Second Class</td>
      <td>Consumer</td>
      <td>United States</td>
      <td>Henderson</td>
      <td>Kentucky</td>
      <td>42420</td>
      <td>South</td>
      <td>Furniture</td>
      <td>Chairs</td>
      <td>FUR-CH-10000454</td>
      <td>600</td>
      <td>730</td>
      <td>3</td>
      <td>3</td>
      <td>21.9</td>
      <td>708.1</td>
      <td>108.1</td>
    </tr>
    <tr>
      <th>2</th>
      <td>3</td>
      <td>2023-01-10</td>
      <td>Second Class</td>
      <td>Corporate</td>
      <td>United States</td>
      <td>Los Angeles</td>
      <td>California</td>
      <td>90036</td>
      <td>West</td>
      <td>Office Supplies</td>
      <td>Labels</td>
      <td>OFF-LA-10000240</td>
      <td>10</td>
      <td>10</td>
      <td>2</td>
      <td>5</td>
      <td>0.5</td>
      <td>9.5</td>
      <td>-0.5</td>
    </tr>
  </tbody>
</table>
</div>




```python
# Convert date from object data type to datetime
df["order_date"] = pd.to_datetime(df["order_date"], format="%Y-%m-%d")

# Drop `cost_price`, `list_price` & `discount_percent` columns
df.drop(columns=["list_price", "cost_price", "discount_percent"], inplace=True)

df.head(3)
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>order_id</th>
      <th>order_date</th>
      <th>ship_mode</th>
      <th>segment</th>
      <th>country</th>
      <th>city</th>
      <th>state</th>
      <th>postal_code</th>
      <th>region</th>
      <th>category</th>
      <th>sub_category</th>
      <th>product_id</th>
      <th>quantity</th>
      <th>discount</th>
      <th>sale_price</th>
      <th>profit</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1</td>
      <td>2023-03-01</td>
      <td>Second Class</td>
      <td>Consumer</td>
      <td>United States</td>
      <td>Henderson</td>
      <td>Kentucky</td>
      <td>42420</td>
      <td>South</td>
      <td>Furniture</td>
      <td>Bookcases</td>
      <td>FUR-BO-10001798</td>
      <td>2</td>
      <td>5.2</td>
      <td>254.8</td>
      <td>14.8</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2</td>
      <td>2023-08-15</td>
      <td>Second Class</td>
      <td>Consumer</td>
      <td>United States</td>
      <td>Henderson</td>
      <td>Kentucky</td>
      <td>42420</td>
      <td>South</td>
      <td>Furniture</td>
      <td>Chairs</td>
      <td>FUR-CH-10000454</td>
      <td>3</td>
      <td>21.9</td>
      <td>708.1</td>
      <td>108.1</td>
    </tr>
    <tr>
      <th>2</th>
      <td>3</td>
      <td>2023-01-10</td>
      <td>Second Class</td>
      <td>Corporate</td>
      <td>United States</td>
      <td>Los Angeles</td>
      <td>California</td>
      <td>90036</td>
      <td>West</td>
      <td>Office Supplies</td>
      <td>Labels</td>
      <td>OFF-LA-10000240</td>
      <td>2</td>
      <td>0.5</td>
      <td>9.5</td>
      <td>-0.5</td>
    </tr>
  </tbody>
</table>
</div>



### 4. Load the data to MySQL Server


```python
# connect with mysql server using sqlalchemy
engine = create_engine("mysql+pymysql://root:root@localhost:3306/orders")
conn = engine.connect()
```


```python
# load the data into sql server using append option
df.to_sql("df_orders", con=conn, index=False, if_exists="append", method="multi")
```




    9994

## Querying in MySQL

![Q 1](QUERY - snippets/1.png)
> ![A 1](1a.png)

![Q 2](2.png)
> ![A 2](2a.png)

![Q 3](3.png)
> ![A 3](3a.png)

![Q 4](4.png)
> ![A 4](4a.png)

![Q 5](5.png)
> ![A 5](5a.png)




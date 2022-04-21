/* Cleaning data in SQL Queries

Skills used : MySQL Functions ( SUBSTRING, SUBSTRING_INDEX, LOCATE, LENGTH),
              Aggregate function (COUNT),
              Group by clause,
              CASE statement,
              Window functions
              CTE Table (WITH clause),
*/


create database portfolio_project_datacleaning;

use portfolio_project_datacleaning;

select *
from nashville_housing;



----------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


select propertyaddress,
	substring(propertyaddress, 1 , locate(',', propertyaddress) -1) as address,
    substring(propertyaddress, locate(',', propertyaddress) +1, length(propertyaddress)) as city
from nashville_housing;

alter table nashville_housing
add property_split_address varchar(255);

update nashville_housing
set property_split_address = substring(propertyaddress, 1 , locate(',', propertyaddress) -1);

alter table nashville_housing
add property_split_city varchar(255);

update nashville_housing
set property_split_city =  substring(propertyaddress, locate(',', propertyaddress) +1, length(propertyaddress));


select owneraddress,
	substring_index(owneraddress, ',',1) as address,
    substring_index(substring_index(owneraddress, ',',2), ',',-1) as city,
	substring_index(substring_index(owneraddress, ',',3),',',-1) as state
from nashville_housing;

alter table nashville_housing
add owner_split_address varchar(255);

update nashville_housing
set owner_split_address = substring_index(owneraddress, ',',1) ;

alter table nashville_housing
add owner_split_city varchar(255);

update nashville_housing
set owner_split_city = substring_index(substring_index(owneraddress, ',',2), ',',-1) ;

alter table nashville_housing
add owner_split_state varchar(255);

select *
from nashville_housing;

----------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "SoldasVacant" field

select distinct (soldasvacant), count(soldasvacant)
from nashville_housing
group by soldasvacant
order by 2;

select soldasvacant,
       case when soldasvacant = 'Y' then 'YES'
            when soldasvacant = 'N' then 'NO'
		else soldasvacant
        end
from  nashville_housing;

update nashville_housing
set soldasvacant =  case when soldasvacant = 'Y' then 'YES'
					     when soldasvacant = 'N' then 'NO'
		            else soldasvacant
                    end;


----------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with RowNum as
(select *,
row_number() over (partition by parcelID,propertyaddress,saledate,saleprice,legalreference 
                   order by uniqueID) row_num
from nashville_housing
) 

delete
from RowNum
where row_num > 1;


----------------------------------------------------------------------------------------------------------

-- Delete unused coloumns 

select *
from nashville_housing;

alter table nashville_housing
drop column propertyaddress , 
drop column owneraddress , 
drop column  taxdistrict;
                    
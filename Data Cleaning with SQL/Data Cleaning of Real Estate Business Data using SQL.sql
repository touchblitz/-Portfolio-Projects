--Data Cleaning in SQL

select * 
from PortfolioProject.dbo.BlitzHousing
--Getting current date from sql
select 
convert(date, getdate())  date


--Standardize Date Format
select SaleDate
from PortfolioProject.dbo.BlitzHousing


update BlitzHousing
set SaleDate = CONVERT(date,SaleDate)

update BlitzHousing
set SaleDate = CAST(SaleDate as date)

alter table BlitzHousing
add SaleDateConverted date

select SaleDateConverted
from BlitzHousing

Update BlitzHousing
set SaleDateConverted = convert(date, SaleDate)

--Deleting the unnecessary columns
alter table BlitzHousing
drop column SaleDate, SaleDateCoverted

--Populate empty Property Address
select * 
from BlitzHousing
--where PropertyAddress is null
order by ParcelID

--Joing the BlitzHousing table to it self

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress , b.PropertyAddress)
from PortfolioProject.dbo.BlitzHousing a 
join PortfolioProject.dbo.BlitzHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Populate the null property addresses
update a
set PropertyAddress = isnull(a.PropertyAddress , b.PropertyAddress)
from PortfolioProject.dbo.BlitzHousing a 
join PortfolioProject.dbo.BlitzHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--Verifying there is null in property addresses
select PropertyAddress, ParcelID
from BlitzHousing
where PropertyAddress is null

--Separating the town from the Property Address
select PropertyAddress
from BlitzHousing

--Removing anything after the comma and the comma itself
Select
SUBSTRING( PropertyAddress,1,charindex (',', PropertyAddress)-1) as Address,
SUBSTRING (PropertyAddress,CHARINDEX (',', PropertyAddress) +1, LEN(PropertyAddress) ) as address

from BlitzHousing

--Adding new columns in the table for the separated address
alter table BlitzHousing
add PropertySplitAddress nvarchar(255)

update BlitzHousing
set PropertySplitAddress = SUBSTRING( PropertyAddress,1,charindex (',', PropertyAddress)-1)

alter table BlitzHousing
add PropertySplitCity nvarchar(255)

update BlitzHousing
set PropertySplitCity = SUBSTRING (PropertyAddress,CHARINDEX (',', PropertyAddress) +1, LEN(PropertyAddress) )

--Onto splitting Owner Address
select OwnerAddress
from PortfolioProject.dbo.BlitzHousing 

Select 
parsename(REPLACE( OwnerAddress,',','.'),3),
parsename(REPLACE( OwnerAddress,',','.'),2),
parsename(REPLACE( OwnerAddress,',','.'),1)
from PortfolioProject.dbo.BlitzHousing

--Creation of 3 new columns and fill with the owner's
Alter table PortfolioProject.dbo.BlitzHousing
add OwnerSplitAddress nvarchar(255)

Update PortfolioProject.dbo.BlitzHousing
set OwnerSplitAddress = parsename(REPLACE( OwnerAddress,',','.'),3)


Alter table PortfolioProject.dbo.BlitzHousing
add OwnerSplitCity nvarchar(255)
Update PortfolioProject.dbo.BlitzHousing
set OwnerSplitCity = parsename(REPLACE( OwnerAddress,',','.'),2)

Alter table PortfolioProject.dbo.BlitzHousing
add OwnerSplitState nvarchar(255)
Update PortfolioProject.dbo.BlitzHousing
set OwnerSplitState = parsename(REPLACE( OwnerAddress,',','.'),1)

-- Changing Y or N to Yes and No on the SoldAsVacant

select SoldAsVacant, count (SoldAsVacant)
from PortfolioProject.dbo.BlitzHousing
group by SoldAsVacant
order  by 2

Select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
      when SoldAsVacant = 'N' then 'No'
	  Else SoldAsVacant
	  End
from PortfolioProject.dbo.BlitzHousing
 
 update PortfolioProject.dbo.BlitzHousing
 set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
      when SoldAsVacant = 'N' then 'No'
	  Else SoldAsVacant
	  End 

	  --Removing Duplicates
with RowDuplicates as(
select *,
      ROW_NUMBER() over (
	  partition by Propertysplitaddress,
	               ParcelID,
				   SalePrice,LegalReference,
				   TotalValue,
				   BuildingValue
				   Order by
				   UniqueID
				   )row_num
from PortfolioProject.dbo.BlitzHousing
--order by PropertyAddress)
)
delete 
from RowDuplicates
where row_num > 1

--delete unused columns

select * 
from PortfolioProject.dbo.BlitzHousing

Alter table  PortfolioProject.dbo.BlitzHousing
drop column PropertyAddress,OwnerAddress, TaxDistrict

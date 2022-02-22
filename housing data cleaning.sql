-- First check
select * from Housing.dbo.NashvilleHousing

-------------------------------------------------------------------------

-- Select database
use Housing

-------------------------------------------------------------------------

-- Standardize date format
select SaleDate, cast(SaleDate as date)
from NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted date

update NashvilleHousing
set SaleDateConverted = cast(SaleDate as date)

select SaleDateConverted 
from NashvilleHousing

-------------------------------------------------------------------------

-- Populate property address data
select * 
from NashvilleHousing
-- where PropertyAddress is null 
order by ParcelID

-- From this, we see that there are 29 PropertyAddresses with null values
-- We also notice that there are properties with the same PropertyAddress and ParcelID 
-- So we assume that if they have the same ParcelID, but different PropertyAddress (null) it is exactly the same
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing as a
join NashvilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing as a
join NashvilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-------------------------------------------------------------------------

-- Spliting Addresses into seperated columns
select PropertyAddress from NashvilleHousing

select 
substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as Address,
substring (PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress)) as City
from NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity = substring (PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress))

select * from NashvilleHousing


select
parsename(replace(OwnerAddress, ',', '.'), 3) as Address,
parsename(replace(OwnerAddress, ',', '.'), 2) as City,
parsename(replace(OwnerAddress, ',', '.'), 1) as State
from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255)

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1)

select * from NashvilleHousing

-------------------------------------------------------------------------

-- Change Y and N to Yes and No in SoldAsVacant
select distinct(SoldAsVacant)
from NashvilleHousing

select distinct(SoldAsVacant), count(SoldAsVacant) as CountAnswers
from NashvilleHousing
group by SoldAsVacant
order by CountAnswers

select SoldAsVacant, 
case
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant =
case
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end

case
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end

-------------------------------------------------------------------------

-- Remove duplicates
-- The best method is to create a temp table and work there
-- But now for educational purposes, we will adjust the original table
-- We are going to remove 104 duplicates and remain 56.373 from 56.478 records

with RowNumCTE as
(
select *, row_number() over 
(partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueID) as RowNum
from NashvilleHousing
--order by ParcelID
)

--select count(RowNum) as count_many
--from RowNumCTE
--group by RowNum

--select *
--from RowNumCTE
--where RowNum > 1
--order by ParcelID

delete
from RowNumCTE
where RowNum > 1

-------------------------------------------------------------------------

-- Delete unused columns and rename some other columns
select * from NashvilleHousing

alter table NashvilleHousing
drop column PropertyAddress, OwnerAddress, SaleDate, TaxDistrict

EXEC sp_rename 'dbo.NashvilleHousing.PropertySplitAddress', 'PropertyAddress', 'COLUMN'
EXEC sp_rename 'dbo.NashvilleHousing.PropertySplitCity', 'PropertyCity', 'COLUMN'
EXEC sp_rename 'dbo.NashvilleHousing.OwnerSplitAddress', 'OwnerAddress', 'COLUMN'
EXEC sp_rename 'dbo.NashvilleHousing.OwnerSplitCity', 'OwnerCity', 'COLUMN'
EXEC sp_rename 'dbo.NashvilleHousing.OwnerSplitState', 'OwnerState', 'COLUMN'

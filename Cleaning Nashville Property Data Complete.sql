
-- Cleaning Data Project Using SQL:
Select *
from PortfolioProject..NashvilleHousing
-------------------------------------------------------------------------------------------------------------------------------------

-- Standardise data format

Select SaleDateConverted, CONVERT(date, SaleDate) 
from PortfolioProject..NashvilleHousing

update NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate) 

ALTER TABLE NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate) 

---------------------------------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address

Select *
from PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

---------------------------------------------------------------------------------------------------------------------------------------------------
-- Breaking out  Address into Individicual Columns (Address, City, State)

Select PropertyAddress
from PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address   -- The -1 here deletes the comma from the updated address set!
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address -- +1 here is one AFTER the comma!
from PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE NashvilleHousing
add PropertySplitCity Nvarchar(255);

update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
from PortfolioProject..NashvilleHousing
---------------------------------------------------------------------------------------------------------------------------------------------------

--Spliting the Owner Address in a more simple way than above by using PARSENAME() (which works backwards to SUBSTRING())

SELECT OwnerAddress
from PortfolioProject..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
from PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE NashvilleHousing
add OwnerSplitState Nvarchar(255);

update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

-- Now they have all been ALTER TABLE functioned and then updated View the entire table at:

SELECT *
from PortfolioProject..NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field: because there is mixed data right now

SELECT distinct (SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant
,CASE when SoldAsVacant = 'Y' THEN 'Yes'
	  when SoldAsVacant = 'N' THEN 'NO'
	  ELSE SoldAsVacant
	  END
from PortfolioProject..NashvilleHousing

update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	  when SoldAsVacant = 'N' THEN 'NO'
	  ELSE SoldAsVacant
	  END

-- now run this and there will be no more Y/N data:

SELECT distinct (SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

---------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates in the Dataset using a CTE
-- First set up the CTE outline:
-- this CTE outline basically pulls all of the duplciates from the data and shows them when executed:

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

from PortfolioProject..NashvilleHousing
--order by ParcelID
)
SELECT *
from RowNumCTE
Where row_num>1
order by PropertyAddress

-- In order to DELETE the Duplicates, this is how its done: When executes 104 rows will be affected (deleted). (replaced 2nd select with delete and
-- removed the order by) after this, if you run the above CTE code again the duplicates will be gone!

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

from PortfolioProject..NashvilleHousing
--order by ParcelID
)
DELETE
from RowNumCTE
Where row_num>1

-- run this to check the outcome (wont be noticable though due to large dataset)
SELECT *
from PortfolioProject..NashvilleHousing


---------------------------------------------------------------------------------------------------------------------------------------------------
--Delete unused columns (simple and easy)

SELECT *
from PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate
---------------------------------------------------------------------------------------------------------------------------------------------------
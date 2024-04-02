	/*Nashville Housing Database Data Cleaning
	*/

-- To view the entire database:

SELECT *
FROM PortfolioProject..NashvilleHousing;

-- 1. Date Format: Standardizing the Date Format

SELECT ConvertedSaleDate, CONVERT(date,SaleDate)
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD ConvertedSaleDate date

UPDATE NashvilleHousing
SET ConvertedSaleDate = CONVERT(date,SaleDate)
;

--2. Populating Property Address Data

SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY 2; --Ordering by ParcelID column to identify duplicate ParcelID entries from the same PropertyAddress

SELECT *
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY 2;


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
;

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL; 


--3. Breaking out Address into Individual Columns (Address, City, State)

	--i. Property Address

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject..NashvilleHousing;

ALTER TABLE NashvilleHousing	--to create a new column with Property Address details
ADD PropertySplitAddress nvarchar(255); 

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)
;

ALTER TABLE NashvilleHousing	--to create a new column with Property City details
ADD PropertySplitCity nvarchar(255); 

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))
;

	-- ii. Owner Address 

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing;

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM PortfolioProject..NashvilleHousing;

ALTER TABLE NashvilleHousing	--to create a new column with owner address details
ADD OwnerSplitAddress nvarchar(255); 

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing	--to create a new column with owner city details
ADD OwnerSplitCity nvarchar(255); 

UPDATE NashvilleHousing
SET PropertySplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing	--to create a new column with owner State details
ADD OwnerSplitState nvarchar(255); 

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

SELECT OwnerAddress, OwnerSplitCity, OwnerSplitAddress, OwnerSplitState
FROM PortfolioProject..NashvilleHousing;

-- 4. Replace Y and N in 'Sold as Vacant' column to Yes and No

SELECT DISTINCT SoldAsVacant, COUNT (SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject..NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END;

-- 5. Removing Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) row_num

FROM PortfolioProject..NashvilleHousing
-- ORDER BY ParcelID
)
SELECT * 
FROM RowNumCTE
WHERE row_num>1
ORDER BY PropertyAddress; -- this CTE identifies duplicate data from the table


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) row_num

FROM PortfolioProject..NashvilleHousing
)
DELETE FROM RowNumCTE
WHERE row_num>1 -- this query deletes identified duplicate data from the table



-- 6. Deleting Unused Columns

SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate






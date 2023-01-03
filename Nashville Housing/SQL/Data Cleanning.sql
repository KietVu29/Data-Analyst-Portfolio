-- Data Source: https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/Nashville%20Housing%20Data%20for%20Data%20Cleaning.xlsx

-- Observe Nashville Housing Data
SELECT *
FROM PortfolioProject..NashvilleHousing
ORDER BY 1


----------------------------------------------------------------------------
-- Standardize Date Format
ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)


----------------------------------------------------------------------------
-- Populate Property Address
-- Check for NULL Address that have duplicated ParcelID
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Update Data
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


----------------------------------------------------------------------------
-- Split Address into Individual Columns (Address, City, State)
-- Split Property Address
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
		SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))AS City
FROM PortfolioProject..NashvilleHousing

-- Update Data
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(225),
	PropertyCity nvarchar(225);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
	PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


-- Split Owner Address
SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerSplitAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerState
FROM PortfolioProject..NashvilleHousing

--Update Data
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddressAddress nvarchar(225),
	OwnerCity nvarchar(225),
	OwnerState nvarchar(225);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) ,
	OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) ,
	OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


----------------------------------------------------------------------------
-- Standardize SoldAsVacant field
-- Check the distinct value in SoldAsVacant
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

-- Since Yes and No is more popular in that dataset, SoldAsVacant will be standardized to have only Yes and No 
SELECT SoldAsVacant,
CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant

-- Update Data
UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END


----------------------------------------------------------------------------
-- Remove Duplicates that have the same ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference)
WITH RowNumCTE AS (
SELECT *, ROW_NUMBER() OVER 
		(PARTITION BY	ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
		ORDER BY uniqueID) row_num
FROM PortfolioProject..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

----------------------------------------------------------------------------
-- Delete Unused Columns
ALTER TABLE NashvilleHousing
DROP COLUMN	PropertyAddress,
			SaleDate,
			OwnerAddress,
			TaxDistrict;

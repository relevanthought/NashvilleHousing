SELECT *
FROM Projects..NashvilleHousing

-- Format Sale Date

SELECT SaleDateConverted
FROM Projects..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted date

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

-- Populate property address data
-- Some values have null property address

SELECT *
FROM Projects..NashvilleHousing
WHERE PropertyAddress is NULL
ORDER BY ParcelID


SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM Projects..NashvilleHousing AS A
JOIN Projects..NashvilleHousing AS B
   ON A.ParcelID = B.ParcelID
   AND A.[UniqueID] <> B.[UniqueID]
WHERE A.PropertyAddress is NULL


UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM Projects..NashvilleHousing AS A
JOIN Projects..NashvilleHousing AS B
   ON A.ParcelID = B.ParcelID
   AND A.[UniqueID] <> B.[UniqueID]
WHERE A.PropertyAddress is NULL

-- Breaking Address Column into Address, City and State Columns

SELECT *
FROM Projects..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM Projects..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))


SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM Projects..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


-- Change Y and N to "Yes" and "No" in "SoldAsVacant"

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM Projects..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID, PropertyAddress,SaleDate, SalePrice, LegalReference ORDER BY UniqueID) row_num

FROM Projects..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1



-- Delete unneccessary columns

ALTER TABLE Projects..NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress

SELECT *
FROM Projects..NashvilleHousing

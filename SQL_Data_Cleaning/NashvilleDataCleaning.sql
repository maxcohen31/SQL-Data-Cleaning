-- Data View

SELECT * FROM Nashville;

-- Removing zeros from SaleDate column

SELECT CONVERT(date, Nashville.SaleDate)
FROM Nashville;

-- Updating table

UPDATE Nashville SET Nashville.SaleDate = CONVERT(date, Nashville.SaleDate);

-- Adding column

ALTER TABLE Nashville
ADD SaleDateConverted date;

UPDATE Nashville SET SaleDateConverted = CONVERT(date, SaleDate);

SELECT SaleDateConverted FROM Nashville;

-- Populate property address

SELECT PropertyAddress FROM Nashville
WHERE PropertyAddress IS NULL;

SELECT first_table.ParcelID, 
	first_table.PropertyAddress, 
	second_table.ParcelID, 
	second_table.PropertyAddress,
	ISNULL(first_table.PropertyAddress, second_table.PropertyAddress)
FROM Nashville first_table
JOIN Nashville second_table
	ON first_table.ParcelID = second_table.ParcelID
	AND first_table.[UniqueID ] <> second_table.[UniqueID ]
WHERE first_table.PropertyAddress IS NULL;

UPDATE first_table
SET first_table.PropertyAddress = ISNULL(first_table.PropertyAddress, second_table.PropertyAddress)
FROM Nashville first_table
JOIN Nashville second_table
	ON first_table.ParcelID = second_table.ParcelID
	AND first_table.[UniqueID ] <> second_table.[UniqueID ]
WHERE first_table.PropertyAddress IS NULL;

-- Breaking out address into individual columns

SELECT Nashville.PropertyAddress
FROM Nashville;

SELECT 
SUBSTRING(Nashville.PropertyAddress, 1, CHARINDEX(',', Nashville.PropertyAddress) -1 ) AS Address,
SUBSTRING(Nashville.PropertyAddress, CHARINDEX(',', Nashville.PropertyAddress) + 1, LEN(Nashville.PropertyAddress)) As Address1
FROM Nashville;	

ALTER TABLE Nashville
ADD PropertySplitAddress NVARCHAR(255);

UPDATE Nashville SET PropertySplitAddress = SUBSTRING(Nashville.PropertyAddress, 1, CHARINDEX(',', Nashville.PropertyAddress) -1 );

ALTER TABLE Nashville
ADD PropertySplitCity NVARCHAR(255);

UPDATE Nashville SET PropertySplitCity = SUBSTRING(Nashville.PropertyAddress, CHARINDEX(',', Nashville.PropertyAddress) + 1, LEN(Nashville.PropertyAddress));

SELECT Nashville.PropertySplitAddress, Nashville.PropertySplitCity 
FROM Nashville;

-- Working on OwnerAddress column

SELECT Nashville.OwnerAddress 
FROM Nashville

SELECT 
PARSENAME(REPLACE(Nashville.OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(Nashville.OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(Nashville.OwnerAddress, ',', '.'), 1)
FROM Nashville

ALTER TABLE Nashville
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE Nashville SET OwnerSplitAddress = PARSENAME(REPLACE(Nashville.OwnerAddress, ',', '.'), 3);

ALTER TABLE Nashville
ADD OwnerSplitCity NVARCHAR(255);

UPDATE Nashville SET OwnerSplitCity =  PARSENAME(REPLACE(Nashville.OwnerAddress, ',', '.'), 2);

ALTER TABLE Nashville
ADD OwnerSplitState NVARCHAR(255);

UPDATE Nashville SET OwnerSplitState = PARSENAME(REPLACE(Nashville.OwnerAddress, ',', '.'), 1);

SELECT * FROM Nashville;

-- Working on 'SoldAsVacant' column

SELECT DISTINCT(Nashville.SoldAsVacant), COUNT(Nashville.SoldAsVacant)
FROM Nashville
GROUP BY Nashville.SoldAsVacant
ORDER BY Nashville.SoldAsVacant;

SELECT Nashville.SoldAsVacant,
	CASE WHEN Nashville.SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN Nashville.SoldAsVacant = 'N' THEN 'No'
		 ELSE Nashville.SoldAsVacant
		 END
FROM Nashville;

UPDATE Nashville 
SET Nashville.SoldAsVacant = CASE WHEN Nashville.SoldAsVacant = 'Y' THEN 'Yes'
								  WHEN Nashville.SoldAsVacant = 'N' THEN 'No'
								  ELSE Nashville.SoldAsVacant
								  END;


-- remove duplicates

WITH RowNumberCTE AS (
SELECT *, 
ROW_NUMBER() OVER( PARTITION BY Nashville.ParcelID,
								Nashville.PropertyAddress,
								Nashville.SalePrice,
								Nashville.SaleDate,
								Nashville.LegalReference
								ORDER BY Nashville.UniqueID
								) row_num
FROM Nashville
)
DELETE
FROM RowNumberCTE
WHERE row_num > 1;
					

-- Deleting unused columns

ALTER TABLE Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

ALTER TABLE Nashville
DROP COLUMN SaleDate;

SELECT * FROM Nashville;
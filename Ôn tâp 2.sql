-- Lệnh xóa DB
DROP DATABASE IF EXISTS QL_DoAn ;
-- Lệnh dùng tạo DB
CREATE DATABASE QL_DoAn ;
-- Sử dụng DB
USE QL_DoAn ;

-- Tạo Bảng Database
DROP TABLE IF EXISTS GiangVien;
CREATE TABLE GiangVien (
	Id_GV TINYINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    Ten_GV VARCHAR(50) NOT NULL,
	Tuoi TINYINT UNSIGNED,
    HocVI VARCHAR(50) NOT NULL
);

DROP TABLE IF EXISTS SinhVien;
CREATE TABLE SinhVien (
	Id_SV TINYINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    Ten_SV VARCHAR(50) NOT NULL,
	NamSinh YEAR DEFAULT NULL,
    QueQuan VARCHAR(50) NOT NULL
);

DROP TABLE IF EXISTS DeTai;
CREATE TABLE DeTai (
	Id_DeTai TINYINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    Ten_DeTai VARCHAR(50) NOT NULL
);

DROP TABLE IF EXISTS HuongDan;
CREATE TABLE HuongDan (
	Id TINYINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    Id_SV TINYINT UNSIGNED,
	Id_DeTai TINYINT UNSIGNED,
	Id_GV TINYINT UNSIGNED,
	Diem SMALLINT UNSIGNED,
    FOREIGN KEY (Id_SV) REFERENCES sinhvien (Id_SV),
	FOREIGN KEY (Id_GV) REFERENCES giangvien (Id_GV),
	FOREIGN KEY (Id_DeTai) REFERENCES detai(Id_DeTai)
);

-- INSERT DB
INSERT INTO detai (Ten_DeTai)
VALUES				('Detai 1'),
					('Detai 2'),
					('Detai 3'),
					('Detai 4'),
					('Detai 5'),
					('Detai 6'),
					('Detai 7'),
					('Detai 8'),
					('Detai 9'),
					('Detai 10');
                    
INSERT INTO giangvien (Ten_GV, Tuoi, HocVi)
VALUES 					('GVv 1', 30 , 'Ths'),
						('GVv 2', 40 , 'PGS'),
						('GVv 3', 36 , 'Ths'),
						('GVv 4', 55 , 'GS'),
						('GVv 5', 45 , 'Ths');
                        
INSERT INTO sinhvien (Ten_SV, NamSinh, QueQuan)
VALUES					('SV1', 1990, 'HN'),
						('SV2', 1991, 'HCM'),
						('SV3', 1992, 'DL'),
						('SV4', 1993, 'HCM'),
						('SV5', 1994, 'HN'),
                        ('SV6', 1990, 'HN'),
						('SV7', 1995, 'HCM'),
						('SV8', 1992, 'DL'),
						('SV9', 2000, 'HCM'),
						('SV10', 2001, 'HN');
                        
INSERT INTO huongdan (Id_SV, Id_DeTai, Id_GV)
VALUES				(1, 1, 5),
                    (2, 5, 4),
                    (3, 6, 1),
                    (4, 3, 3),
					(3, 6, 1),
                    (3, 5, 1),
                    (4, 2, 3),
                    (4, 1, 3),
                    (6, 6, 2);
                    
INSERT INTO huongdan (Id_SV, Id_GV)
VALUES				(9, 5),
                    (7, 4),
                    (8, 1),
                    (10,4);
                    
-- Question 
-- 2a Lấy tất cả các sinh viên chưa có đề tài hướng dẫn
SELECT * FROM sinhvien sv 
RIGHT JOIN huongdan hd ON hd.Id_SV = sv.Id_SV
WHERE hd.Id_DeTai is NULL;

-- 2b Lấy ra số sinh viên làm đề tài ‘DeTai 6’
SELECT 'Detai 6', COUNT(1) FROM sinhvien sv 
INNER JOIN huongdan hd ON hd.Id_SV = sv.Id_SV
INNER JOIN detai dt ON dt.Id_DeTai = hd. Id_DeTai
WHERE dt.Ten_DeTai LIKE 'Detai 6';

-- 3 Tạo view có tên là "SinhVienInfo" lấy các thông tin về học sinh bao gồm:
-- mã số, họ tên và tên đề tài
-- (Nếu sinh viên chưa có đề tài thì column tên đề tài sẽ in ra "Chưa có")
DROP VIEW IF EXISTS vw_SinhVienInfo;
CREATE VIEW vw_SinhVienInfo AS
SELECT sv.Id_SV 'Ma so', sv.Ten_SV 'Ho Ten',
											CASE
												WHEN dt.Ten_DeTai IS NOT NULL 
													THEN dt.Ten_DeTai
												WHEN dt.Ten_DeTai IS NULL 
													THEN 'Chua co De Tai'
											END
											AS 'De Tai'
FROM sinhvien sv 
LEFT JOIN huongdan hd ON hd.Id_SV = sv.Id_SV
LEFT JOIN detai dt ON dt.Id_DeTai = hd. Id_DeTai;

SELECT * FROM vw_sinhvieninfo;
-- 4 Tạo trigger cho table SinhVien khi insert sinh viên có năm sinh <= 1950
-- thì hiện ra thông báo "Moi ban kiem tra lai nam sinh"
DROP TRIGGER IF EXISTS Trg_BeforeInsertSV;
DELIMITER $$
CREATE TRIGGER Trg_BeforeInsertSV
   BEFORE INSERT ON sinhvien
   FOR EACH ROW
    BEGIN
        IF(NEW.NamSinh <=1950) THEN
			SIGNAL SQLSTATE '12345'
			SET MESSAGE_TEXT = 'Moi ban kiem tra lai nam sinh';
        END IF;
    END$$
 DELIMITER ;
 
 INSERT INTO sinhvien (Ten_SV, NamSinh, QueQuan)
 VALUES ('SV_Test', 1950, 'HN');

-- 5 Hãy cấu hình table sao cho khi xóa 1 sinh viên nào đó thì sẽ tất cả thông
-- tin trong table HuongDan liên quan tới sinh viên đó sẽ bị xóa đi
ALTER TABLE huongdan
DROP CONSTRAINT huongdan_ibfk_1;
ALTER TABLE huongdan
ADD CONSTRAINT fk_HuongDan_SinhVien FOREIGN KEY (Id_SV) REFERENCES sinhvien(Id_SV) ON DELETE CASCADE;


-- 6 Viết 1 Procedure để khi nhập vào tên của sinh viên 
-- thì sẽ thực hiện xóa toàn bộ thông tin liên quan của sinh viên trên hệ thống: 
DROP PROCEDURE IF EXISTS sp_DeleteSV;
DELIMITER $$
CREATE PROCEDURE sp_DeleteSV(IN inputSV VARCHAR(30)) 
BEGIN
	DECLARE chkId TINYINT DEFAULT 0;
    SELECT Id_SV INTO chkId FROM sinhvien WHERE Ten_SV LIKE inputSV;
	DELETE FROM huongdan WHERE Id_SV = chkId;
	DELETE FROM sinhvien WHERE Id_SV = chkId;
END$$
DELIMITER ;

CALL sp_DeleteSV ('SV1');
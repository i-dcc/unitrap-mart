# Sequel Pro dump
# Version 2492
# http://code.google.com/p/sequel-pro
#
# Host: 127.0.0.1 (MySQL 5.0.26)
# Database: biomart_unitrapcore
# Generation Time: 2010-11-12 10:40:23 +0000
# ************************************************************

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Dump of table vector_list
# ------------------------------------------------------------

DROP TABLE IF EXISTS `vector_list`;

CREATE TABLE `vector_list` (
  `vector_db_id` bigint(5) NOT NULL default '0',
  `vector_name` varchar(255) character set utf8 collate utf8_unicode_ci NOT NULL,
  `locus` varchar(255) character set utf8 collate utf8_unicode_ci NOT NULL,
  `acc_no` varchar(30) character set utf8 collate utf8_unicode_ci NOT NULL,
  `provider_name` varchar(255) character set utf8 collate utf8_unicode_ci default NULL,
  `url` varchar(255) character set utf8 collate utf8_unicode_ci default NULL,
  `pubmed_id` varchar(255) character set utf8 collate utf8_unicode_ci default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

LOCK TABLES `vector_list` WRITE;
/*!40000 ALTER TABLE `vector_list` DISABLE KEYS */;
INSERT INTO `vector_list` (`vector_db_id`,`vector_name`,`locus`,`acc_no`,`provider_name`,`url`,`pubmed_id`)
VALUES
	(1,'VICTR76','EU676801','EU676801','Lexicon Pharmaceuticals','http://www.lexicon-genetics.com','18799693'),
	(2,'VICTR75','EU676802','EU676802','Lexicon Pharmaceuticals','http://www.lexicon-genetics.com','18799693'),
	(3,'VICTR74','EU676803','EU676803','Lexicon Pharmaceuticals','http://www.lexicon-genetics.com','18799693'),
	(4,'VICTR48','EU676804','EU676804','Lexicon Pharmaceuticals','http://www.lexicon-genetics.com','18799693'),
	(5,'pT1ATGbetageo','pT1ATGbetageo','IKMC_1','German Gene Trap Consortium (GGTC)','http://www.genetrap.de','10615117'),
	(16,'pT1betageo','pT1betageo','IKMC_2','German Gene Trap Consortium (GGTC)','http://www.genetrap.de','10615117'),
	(28,'U3betageo','U3betageo','IKMC_4','German Gene Trap Consortium (GGTC)','http://www.genetrap.de','10615117'),
	(6,'ROSAbetageo frame+2','ROSAbetageo+2','IKMC_10','German Gene Trap Consortium (GGTC)','http://www.genetrap.de','12904583'),
	(7,'ROSAbetageo frame0','ROSAbetageo0','IKMC_11','German Gene Trap Consortium (GGTC)','http://www.genetrap.de','12904583'),
	(27,'ROSAbetageo frame+1','ROSAbetageo','IKMC_3','German Gene Trap Consortium (GGTC)','http://www.genetrap.de','12904583'),
	(8,'FlipROSACeo frame+2','FlipROSACeoC+2','IKMC_12','German Gene Trap Consortium (GGTC)','http://www.genetrap.de','15870191'),
	(9,'FlipROSAbetageo frame0','FlipROSAbgeo0','IKMC_13','German Gene Trap Consortium (GGTC)','http://www.genetrap.de','15870191'),
	(10,'rFlipROSAbetageoneo* frame+1','rFROSAbgeo+1s','IKMC_14','German Gene Trap Consortium (GGTC)','http://www.genetrap.de','15870191'),
	(11,'rFlipROSAbetageoneo* frame0','rFROSAbgeo0s','IKMC_15','German Gene Trap Consortium (GGTC)','http://www.genetrap.de','15870191'),
	(12,'rFlipROSAbetageoneo* frame+2','rFROSAbgeo+2s','IKMC_16','German Gene Trap Consortium (GGTC)','http://www.genetrap.de','15870191'),
	(13,'rsFlipROSAbetageoneo* frame+1','rsFROSAbgeo+1s','IKMC_17','German Gene Trap Consortium (GGTC)','http://www.genetrap.de','15870191'),
	(14,'rsFlipROSAbetageoneo* frame0','rsFROSAbgeo0s','IKMC_18','German Gene Trap Consortium (GGTC)','http://www.genetrap.de','15870191'),
	(15,'rsFlipROSAbetageoneo* frame+2','rsFROSAbgeo+2s','IKMC_19','German Gene Trap Consortium (GGTC)','http://www.genetrap.de','15870191'),
	(18,'rsFlipROSACeo frame 0','rsFlipROSACeo0','IKMC_21','German Gene Trap Consortium (GGTC)','http://www.genetrap.de','15870191'),
	(30,'FlipROSAbetageo frame+1','FlipROSAbetageo','IKMC_6','German Gene Trap Consortium (GGTC)','http://www.genetrap.de','15870191'),
	(31,'rFlipROSAbetageo frame+1','rFlpROSAbetageo','IKMC_7','German Gene Trap Consortium (GGTC)','http://www.genetrap.de','15870191'),
	(33,'FlipROSACeo frame-2','FlipROSACeoC-2','IKMC_9','German Gene Trap Consortium (GGTC)','http://www.genetrap.de','15870191'),
	(17,'reFlipROSAbetageoneo* frame+1','reFROSAbgeo+1s','IKMC_20','German Gene Trap Consortium (GGTC)','http://www.genetrap.de','18812397'),
	(32,'eFlipROSAbetageo frame+1','eFlpROSAbetageo','IKMC_8','German Gene Trap Consortium (GGTC)','http://www.genetrap.de','18812397'),
	(19,'U3NeoSV1','U3NeoSV1','IKMC_22','Hicks GG','www.EScells.ca',NULL),
	(20,'U3NeoSVFS','U3NeoSVFS','IKMC_23','Hicks GG','www.EScells.ca',NULL),
	(21,'Gen-SD5','Gen-SD5','IKMC_24','Stanford WL','http://www.cmhd.ca',NULL),
	(22,'GepNMDi3','GepNMDi3','IKMC_25','Stanford WL','http://www.cmhd.ca',NULL),
	(23,'Gep-SD5','Gep-SD5','IKMC_26','Stanford WL','http://www.cmhd.ca',NULL),
	(24,'pNMDi3','pNMDi3','IKMC_27','Stanford WL','http://www.cmhd.ca',NULL),
	(25,'pNMDi4','pNMDi4','IKMC_28','Stanford WL','http://www.cmhd.ca',NULL),
	(26,'UPA','UPA','IKMC_29','Stanford WL','http://www.cmhd.ca',NULL),
	(29,'U3Ceo frame 0','U3CEO','IKMC_5','German Gene Trap Consortium (GGTC)','http://www.genetrap.de','11691852');

/*!40000 ALTER TABLE `vector_list` ENABLE KEYS */;
UNLOCK TABLES;





/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

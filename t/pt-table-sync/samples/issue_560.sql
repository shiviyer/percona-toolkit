DROP DATABASE IF EXISTS issue_560;;
CREATE DATABASE issue_560;
USE issue_560;
DROP TABLE IF EXISTS buddy_list;
CREATE TABLE `buddy_list` (
  `player_id` int(10) unsigned NOT NULL default '0',
  `buddy_id` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`player_id`,`buddy_id`)
) ENGINE=InnoDB; 
INSERT INTO buddy_list VALUES (1,9559),(2,3558),(3,6164),(4,9386),(5,7431),(6,1660),(7,6861),(8,8833),(9,509),(10,1885),(11,9862),(12,2456),(13,8556),(14,7147),(15,7523),(16,1418),(17,7872),(18,4321),(19,7354),(20,448),(21,5238),(22,8700),(23,4560),(24,8640),(25,1403),(26,4459),(27,668),(28,4239),(29,3621),(30,5248),(31,7625),(32,9037),(33,8016),(34,7086),(35,1830),(36,811),(37,5267),(38,8492),(39,5235),(40,9067),(41,2565),(42,6776),(43,5243),(44,8985),(45,2465),(46,1214),(47,3045),(48,5884),(49,4661),(50,2551),(51,2165),(52,1824),(53,132),(54,8478),(55,8251),(56,2434),(57,2361),(58,8280),(59,5080),(60,5157),(61,6652),(62,9085),(63,4753),(64,5333),(65,3804),(66,5820),(67,6293),(68,8777),(69,6959),(70,7161),(71,2246),(72,4523),(73,2128),(74,8104),(75,8169),(76,9319),(77,1229),(78,4078),(79,2559),(80,2530),(81,7322),(82,2319),(83,2103),(84,1541),(85,1653),(86,9031),(87,8224),(88,305),(89,1066),(90,9152),(91,9513),(92,7824),(93,7942),(94,2567),(95,1536),(96,6074),(97,7074),(98,2637),(99,951),(100,4034),(101,9455),(102,1087),(103,7159),(104,3441),(105,9970),(106,6601),(107,8767),(108,3607),(109,8116),(110,1953),(111,7727),(112,5024),(113,284),(114,7894),(115,4647),(116,691),(117,1690),(118,8178),(119,9804),(120,8332),(121,1839),(122,3660),(123,5854),(124,7491),(125,1361),(126,8908),(127,7103),(128,1314),(129,478),(130,9738),(131,3008),(132,590),(133,1084),(134,6890),(135,8898),(136,6010),(137,9834),(138,9957),(139,7841),(140,5930),(141,8716),(142,6959),(143,4201),(144,81),(145,731),(146,1575),(147,1529),(148,2410),(149,524),(150,200),(151,6476),(152,7668),(153,5620),(154,385),(155,2921),(156,9591),(157,1381),(158,6899),(159,9394),(160,2955),(161,8479),(162,130),(163,1253),(164,5873),(165,2659),(166,7639),(167,1461),(168,2109),(169,3584),(170,4779),(171,9814),(172,9704),(173,8651),(174,5999),(175,6234),(176,1865),(177,3647),(178,8942),(179,5402),(180,7846),(181,210),(182,8166),(183,5249),(184,5901),(185,8953),(186,1256),(187,3402),(188,1576),(189,1203),(190,4491),(191,2828),(192,3376),(193,4369),(194,7898),(195,9851),(196,3754),(197,9387),(198,5510),(199,5470),(200,7538),(201,295),(202,8589),(203,9928),(204,7199),(205,8354),(206,307),(207,3663),(208,6115),(209,7041),(210,5397),(211,7004),(212,7481),(213,1280),(214,8175),(215,637),(216,9390),(217,9435),(218,5447),(219,7566),(220,1358),(221,438),(222,5547),(223,862),(224,6308),(225,9970),(226,2263),(227,5145),(228,5414),(229,8615),(230,8861),(231,853),(232,3721),(233,4286),(234,6868),(235,701),(236,8152),(237,9916),(238,653),(239,6283),(240,8994),(241,2382),(242,8991),(243,7841),(244,2797),(245,7766),(246,511),(247,2295),(248,1587),(249,2591),(250,809),(251,8716),(252,7347),(253,7374),(254,4759),(255,8430),(256,4918),(257,3039),(258,437),(259,458),(260,3062),(261,8384),(262,8716),(263,5658),(264,5880),(265,7106),(266,127),(267,2636),(268,2476),(269,1013),(270,3215),(271,604),(272,5675),(273,5223),(274,4549),(275,3367),(276,3298),(277,5548),(278,2710),(279,1262),(280,2323),(281,5210),(282,7843),(283,5411),(284,5090),(285,802),(286,5725),(287,9258),(288,2128),(289,7360),(290,4253),(291,3907),(292,1515),(293,1809),(294,9668),(295,6003),(296,4695),(297,8461),(298,6032),(299,4200),(300,2085),(301,887),(302,1116),(303,3983),(304,3641),(305,1016),(306,4071),(307,1678),(308,3887),(309,9012),(310,9547),(311,9862),(312,3082),(313,112),(314,1212),(315,5442),(316,5516),(317,6419),(318,7189),(319,3076),(320,8163),(321,543),(322,5600),(323,4229),(324,2614),(325,2280),(326,193),(327,2154),(328,6436),(329,1079),(330,1554),(331,6052),(332,6806),(333,3414),(334,6626),(335,1148),(336,5719),(337,1129),(338,8434),(339,2717),(340,7587),(341,1039),(342,4931),(343,219),(344,3242),(345,7378),(346,3791),(347,6564),(348,9777),(349,2796),(350,2454),(351,7697),(352,317),(353,4503),(354,5638),(355,9606),(356,7505),(357,4478),(358,7382),(359,5742),(360,6568),(361,4538),(362,164),(363,4528),(364,9400),(365,2232),(366,9018),(367,8102),(368,7841),(369,4058),(370,5378),(371,2975),(372,8621),(373,1308),(374,715),(375,6413),(376,2301),(377,7004),(378,8256),(379,8991),(380,5697),(381,1920),(382,6950),(383,989),(384,9952),(385,3651),(386,2801),(387,4506),(388,1766),(389,6219),(390,1081),(391,3104),(392,1842),(393,3019),(394,9073),(395,9388),(396,4689),(397,2941),(398,3109),(399,8402),(400,6530),(401,6830),(402,8776),(403,717),(404,836),(405,7918),(406,7426),(407,5270),(408,3072),(409,8019),(410,1215),(411,4643),(412,820),(413,9309),(414,8969),(415,7730),(416,1724),(417,5764),(418,4592),(419,9525),(420,8381),(421,6112),(422,2451),(423,9767),(424,5851),(425,2021),(426,1499),(427,824),(428,7769),(429,7377),(430,3438),(431,6837),(432,1109),(433,1605),(434,4207),(435,6695),(436,6485),(437,7342),(438,1899),(439,781),(440,862),(441,9039),(442,4873),(443,8155),(444,7052),(445,8688),(446,8565),(447,6339),(448,31),(449,567),(450,8170),(451,9245),(452,3578),(453,2039),(454,1938),(455,1059),(456,3073),(457,9010),(458,8983),(459,714),(460,6343),(461,4952),(462,9134),(463,5472),(464,5641),(465,2469),(466,5800),(467,5390),(468,361),(469,7684),(470,6834),(471,7153),(472,3619),(473,5265),(474,1240),(475,4638),(476,1919),(477,6244),(478,9615),(479,495),(480,7691),(481,993),(482,4722),(483,3087),(484,503),(485,5458),(486,1660),(487,3850),(488,6382),(489,3022),(490,8738),(491,3146),(492,2145),(493,6070),(494,4431),(495,7083),(496,5597),(497,7429),(498,9383),(499,1746),(500,4272);

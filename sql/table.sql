CREATE TABLE `userpositions` (
 `userid` int(10) unsigned NOT NULL,
 `dateline` int(10) unsigned NOT NULL DEFAULT '0',
 `lat` double NOT NULL DEFAULT '0',
 `lon` double NOT NULL DEFAULT '0',
 `status` tinyint(4) NOT NULL DEFAULT '0',
 `icon` tinyint(4) NOT NULL DEFAULT '0',
 PRIMARY KEY (`userid`),
 KEY `lat` (`lat`,`lon`,`status`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251
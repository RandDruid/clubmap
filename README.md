# ClubMap
Multi-platform application to show positions of forum members on map. It is created for [Forester-MoscowClub][51a41858] but with small modifications can work with other forums or stand alone.
## Status
Currently project is in Alpha version. Limited set of basic functions already work fine, but serious changes are very possible. Master branch should be relatively stable at all times, but in alpha stage compatibility between versions may be broken at any moment.
## Details
Project have client and server parts. Server part consists of PHP page on server, working in a context of [vBulletin][4a11d219] forum and database table. PHP page use standard forum authentication and database access functions. It works with separate SQL table in forum standard database.

Application was created to work with vBulletin v.3.8.7, but it shouldn't be difficult to adopt it to other versions. To use application outside of forum infrastructure, you should build your own authentication scheme.

Current project version created with [Qt][135ec22f] version 5.11.2. It compiles under Linux, Windows and Android. If connection to forum works over HTTPS (as in our case), [OpenSSL][33ce3abc] 1.0.* libraries are required on Linux and Android.

Application use QtLocation & QtPosition modules and [Open Street Map][1bd6bc8a] plugin.
## Roadmap
- Testing on all platforms
- Additional functionality (icons, statuses etc.)
- Better integration with forum (e.g. work with private messages)
- Closed tests from Google Play Store
- iOS version

## License
Project is licensed under [LGPLv3][e2b3abe9].

  [51a41858]: https://forester.club "Forester-MoscowClub"
  [4a11d219]: https://www.vbulletin.com/ "vBulletin"
  [33ce3abc]: https://www.openssl.org/ "OpenSSL"
  [135ec22f]: https://www.qt.io/ "Qt"
  [1bd6bc8a]: https://www.openstreetmap.org "OSM"
  [e2b3abe9]: https://github.com/RandDruid/clubmap/blob/master/LICENSE "LGPLv3"

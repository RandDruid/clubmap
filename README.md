# ClubMap
Multi-platform application to show positions of forum members on a map. It is created for [Forester-MoscowClub][51a41858] but with small modifications can work with other forums or standalone.
## Status
Currently the project is in Alpha version. A limited set of basic functions already works fine, but serious changes are very possible. The master branch should be relatively stable at all times, but in alpha stage compatibility between versions may be broken at any moment.
## Details
The project has client and server parts. The server part consists of a PHP page on a server working in a context of [vBulletin][4a11d219] forum and a database table. The PHP page uses standard forum authentication and database access functions. It works with a separate SQL table in the standard forum database.

The application was created to work with vBulletin v.3.8.7, but it shouldn't be difficult to adapt it to other versions. To use the application outside of the forum infrastructure, you should build your own authentication scheme.

The current project version was created with [Qt][135ec22f] version 5.11.2. It compiles under Debian (targets: Debian, Android), Windows (target: Windows). If the connection to the forum works over HTTPS (as in our case), [OpenSSL][33ce3abc] 1.0.* libraries are required on Linux and Android.

The application uses QtLocation & QtPosition modules and [Open Street Map][1bd6bc8a] plugin.
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

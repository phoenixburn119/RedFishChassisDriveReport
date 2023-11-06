# RedFishChassisDriveReport
Pulls a report for all chassis drives in an easy to read CSV. Mainly proof of concept while I get use to RedFish.

The script uses the Swordfish powershell toolkit from Chris Lionett (https://github.com/SNIA/Swordfish-Powershell-Toolkit/tree/master). It will attempt to read from the /source/IDRACSource.csv file and pull credentials to then connect with RedFish to pull all drives and creates an array with relevant information that's easily customizable.

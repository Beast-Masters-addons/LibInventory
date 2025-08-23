# Lib: Inventory
A library to keep track of owned items and mail them to other characters. Written for and used by my addon ProfessionMailer.

The library should be a standalone addon and not embedded in others to keep saved variables available for all addons.

The library uses AceAddon with the following modules:
* LibInventoryBank: Internal methods for scanning of bank slots
* LibInventoryCharacter: Character information
* LibInventoryCharacterObject: An object to store character information. Used in return values
* LibInventoryLocations: Keep track of item locations
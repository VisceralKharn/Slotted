# -*- coding: utf-8 -*-
"""
Created on Fri Aug  5 07:25:37 2022


"""

import requests
import json
from collections import defaultdict


spellSlots = ['Q','W','E','R']


charSpellsDict = defaultdict(dict)

baseCharUrl = "https://raw.communitydragon.org/latest/game/data/characters/"
charList = requests.request(('GET'), 'https://raw.communitydragon.org/latest/cdragon/files.links.txt')

files = [file for file in (charList.text).splitlines() if file[0:21] == 'game/data/characters/' ]

files = [file.split('/') for file in files]

for file in files:
    char = file[3]
    charCap = char.capitalize()
    charFile = f"{baseCharUrl}{char}/{char}.bin.json"
    charRequest = requests.request('GET',charFile)
    
    if charRequest.status_code == 200:
        charJson = json.loads(charRequest.text)
        
        for spellSlot in spellSlots:
            
            try:
                charSpellsDict[charCap][spellSlot] = charJson[f"Characters/{charCap}/Spells/{charCap}{spellSlot}Ability/{charCap}{spellSlot}"]['mSpell']['castRange']
            except:
                pass


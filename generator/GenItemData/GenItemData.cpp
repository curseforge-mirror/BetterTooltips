// GenItemData.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include "pch.h"
#include <iostream>
#include <vector>
#include <algorithm>

#include "..\..\..\..\..\..\Develop\simc-bfa-dev\engine\dbc\dbc.hpp"
#include "..\..\..\..\..\..\Develop\simc-bfa-dev\engine\dbc\generated\sc_item_data.inc"
#include "..\..\..\..\..\..\Develop\simc-bfa-dev\engine\dbc\generated\azerite.inc"
#include "..\..\..\..\..\..\Develop\simc-bfa-dev\engine\dbc\generated\sc_spell_data.inc"
#include "..\..\..\..\..\..\Develop\simc-bfa-dev\engine\dbc\generated\sc_item_data2.inc"

#include <vector>
#include <iostream>
#include <fstream>
#include <iosfwd>
#include <ostream>

std::string ReplaceAll(std::string str, const std::string& from, const std::string& to) {
	size_t start_pos = 0;
	while ((start_pos = str.find(from, start_pos)) != std::string::npos) {
		str.replace(start_pos, from.length(), to);
		start_pos += to.length(); // Handles case where 'to' is a substring of 'from'
	}


	return str;
}

int main()
{
	std::vector<spell_data_t> spellData{ std::begin(__spell_data), std::end(__spell_data) };
	std::vector<spelleffect_data_t> sed{ std::begin(__spelleffect_data), std::end(__spelleffect_data) };

	std::ofstream outs("SpellDump.dat", std::ios::out);

	std::vector< item_data_t> itemData{ std::begin(__item_data), std::end(__item_data) };

	std::vector< azerite_power_entry_t > azeritePowers{ std::begin(__azerite_power_data), std::end(__azerite_power_data) };

	for (auto&& id : itemData)
	{
		if (id.id == 268888)
		{
			std::cout << "ghunn";
		}

		bool header = false;
		// Get the spell reference, if there is one
		for (int Index = 0; Index < MAX_ITEM_EFFECT; Index++)
		{
			
			if (id.trigger_spell[Index] != 0)
			{
				auto spell = std::find_if(spellData.begin(), spellData.end(), [&](auto&& sd)
				{
					return sd._id == id.id_spell[Index];
				});

				if (spell == spellData.end())
					continue;

				if (spell->_rppm == 0 && spell->_proc_chance == 0)
					continue;




				double procChance = spell->_rppm != 0 ? spell->_rppm : spell->_proc_chance;
				if (procChance >= 100)
					continue;

				if (!header)
				{
					outs << "Items[" << id.id << "] = {}" << std::endl;
					header = true;
				}


				bool isRPPM = spell->_rppm != 0;
				outs << "Items[" << id.id << "][\"chance_" << Index << "\"] = " << procChance << std::endl;
				outs << "Items[" << id.id << "][\"chance_" << Index << "_rppm\"] = " << isRPPM << std::endl;
				std::string Description = ReplaceAll(std::string(spell->_name), std::string("'"), std::string("\\'"));
				Description = ReplaceAll(Description, std::string("\""), std::string("\\\""));
				outs << "Items[" << id.id << "][\"chance_" << Index << "_name\"] = " << "\"" << Description << "\"" << std::endl;
				outs << "Items[" << id.id << "][\"chance_" << Index << "_icd\"] = " << spell->_internal_cooldown << std::endl;
			}
		}
	}

	for (auto&& sd : spellData)
	{
		if (sd._id == 255141)
		{
			std::cout << "Runic!";
		}
		// Check if the spell data has an associated spell effect.
		auto refSpell = std::find_if(sed.begin(), sed.end(), [&](auto&& data)
		{
			return data._spell_id == sd._id;
		});

		// refSpell->_id is the actual spell

		// Grab the associated actual spell
		auto actualSpell = std::find_if(spellData.begin(), spellData.end(), [&](auto&& spd)
		{
			return refSpell->_trigger_spell_id == spd._id;
		});

		if (refSpell->_trigger_spell_id == 255151)
		{
			std::cout << "hello";
		}

		bool Header = false;

		if (actualSpell != spellData.end())
		{
			if (actualSpell->_internal_cooldown != 0)
			{
				if (!Header)
				{
					outs << "ItemData[" << sd._id << "] = {}" << std::endl;
					Header = true;
				}
				outs << "ItemData[" << sd._id << "][\"icd\"] = " << actualSpell->_internal_cooldown << std::endl;
			}

			if (actualSpell->_proc_chance == 101 && actualSpell->_rppm == 0 && sd._rppm == 0)
				continue;

			if ((actualSpell->_proc_chance != 0 && actualSpell->_proc_chance < 100) || actualSpell->_rppm != 0)
			{
				if (!Header)
				{
					outs << "ItemData[" << sd._id << "] = {}" << std::endl;
					Header = true;
				}

				bool isRPPM = actualSpell->_rppm != 0;
				outs << "ItemData[" << sd._id << "][\"rppm\"] = " << isRPPM << std::endl;
				double procChance = actualSpell->_rppm != 0 ? actualSpell->_rppm : actualSpell->_proc_chance;
				outs << "ItemData[" << sd._id << "][\"chance\"] = " << procChance << std::endl;
			}
			else if (sd._rppm != 0 || sd._proc_chance != 0)
			{
				if (!Header)
				{
					outs << "ItemData[" << sd._id << "] = {}" << std::endl;
					Header = true;
				}

				bool isRPPM = sd._rppm != 0;
				outs << "ItemData[" << sd._id << "][\"rppm\"] = " << isRPPM << std::endl;
				double procChance = sd._rppm != 0 ? sd._rppm : sd._proc_chance;
				outs << "ItemData[" << sd._id << "][\"chance\"] = " << procChance << std::endl;
			}

		}
		else
		{
			if (sd._internal_cooldown != 0)
			{
				outs << "ItemData[" << sd._id << "] = {}" << std::endl;
				outs << "ItemData[" << sd._id << "][\"icd\"] = " << sd._internal_cooldown << std::endl;
			}

			if (sd._proc_chance == 101 && sd._rppm == 0)
				continue;

			if (sd._proc_chance != 0 || sd._rppm != 0)
			{
				if (!Header)
				{
					outs << "ItemData[" << sd._id << "] = {}" << std::endl;
					Header = true;
				}

				bool isRPPM = sd._rppm != 0;
				outs << "ItemData[" << sd._id << "][\"rppm\"] = " << isRPPM << std::endl;
				double procChance = sd._rppm != 0 ? sd._rppm : sd._proc_chance;
				outs << "ItemData[" << sd._id << "][\"chance\"] = " << procChance << std::endl;

			}
		}

		// If this is an azerite power, map its ID.
		auto power = std::find_if(azeritePowers.begin(), azeritePowers.end(), [&](auto&& power)
		{
			return power.spell_id == sd._id;
		});

		if (power != azeritePowers.end())
		{
			if (!Header)
			{
				outs << "ItemData[" << sd._id << "] = {}" << std::endl;
				Header = true;
			}
			// Ok, write this info
			outs << "ItemData[" << sd._id << "][\"apid\"] = " << power->id << std::endl;
		}
	}

	std::vector< item_enchantment_data_t> enchantsData{ std::begin(__spell_item_ench_data), std::end(__spell_item_ench_data) };

	for (auto&& ie : enchantsData)
	{
		if (ie.id_spell == 0)
			continue;

		outs << "EnchantData[" << ie.id << "] = " << ie.ench_prop[0] << std::endl;
		outs << "EnchantData[" << ie.id_spell << "] = " << ie.ench_prop[0] << std::endl;
	}

}
	
// Run program: Ctrl + F5 or Debug > Start Without Debugging menu
// Debug program: F5 or Debug > Start Debugging menu

// Tips for Getting Started: 
//   1. Use the Solution Explorer window to add/manage files
//   2. Use the Team Explorer window to connect to source control
//   3. Use the Output window to see build output and other messages
//   4. Use the Error List window to view errors
//   5. Go to Project > Add New Item to create new code files, or Project > Add Existing Item to add existing code files to the project
//   6. In the future, to open this project again, go to File > Open > Project and select the .sln file

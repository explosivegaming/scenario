

local Commands = require 'expcore.commands'


Commands.new_command('ratio','This command will give the input and ouput ratios of the selected machine. Use the parameter for calcualting the machines needed for that amount of items per second.')
      :add_param('itemsPerSecond',true,'number')
      :register(function(player,itemsPerSecond,raw)
            
            local machine = player.selected -- selected machine
            if not machine then --nil check
                  return Commands.error{'expcom-ratio.notSelecting'}
            end
            
            if  machine.type ~= "assembling-machine" and machine.type ~= "furnace" then
                  return Commands.error{'expcom-ratio.notSelecting'}
            end
            local recpie =  machine.get_recipe() -- recpie

            if not recpie then --nil check
                  return Commands.error{'expcom-ratio.notSelecting'}
            end

            local items = recpie.ingredients -- items in that recpie
            local product = recpie.products -- output items
            local amountOfMachines
            local moduleInvetory = machine.get_module_inventory()--the module Invetory of the machine
            local mult = Modules(moduleInvetory) --function for the productivety moduals

            if itemsPerSecond then
                  amountOfMachines = math.ceil( AmountOfMachines(itemsPerSecond,1/recpie.energy*machine.crafting_speed*product[1].amount*mult)) -- amount of machines
            end
            if not amountOfMachines then
                  amountOfMachines = 1  --set to 1 to make it not nil
            end
            ----------------------------items----------------------------
            for i, item in ipairs(items) do
                  local sprite -- string to make the icon work either fluid ore item

                  if item.type == "item" then
                        sprite = 'expcom-ratio.item-in'
                  else
                        sprite = 'expcom-ratio.fluid-in'
                  end
                  
                        
                  local ips = item.amount/recpie.energy*machine.crafting_speed*amountOfMachines --math on the items/fluids per second
                  Commands.print {sprite,math.round(ips,3),item.name}-- full string
            end
            ----------------------------products----------------------------
            
            for i, product in ipairs(product) do
                  local sprite  -- string to make the icon work either fluid ore item

                  if product.type == "item" then
                        sprite = 'expcom-ratio.item-out'
                  else
                        sprite = 'expcom-ratio.fluid-out'
                  end

                  local output = 1/recpie.energy*machine.crafting_speed*product.amount*mult  --math on the outputs per second
                  Commands.print {sprite,math.round(output*amountOfMachines,3),product.name} -- full string

            end

            if amountOfMachines ~= 1 then
                  Commands.print{'expcom-ratio.machines',amountOfMachines} 
            end

      end)
function Modules(moduleInvetory) -- returns the multeplier of the modules
      local effect1 = moduleInvetory.get_item_count("productivity-module") -- type 1
      local effect2 = moduleInvetory.get_item_count("productivity-module-2")-- type 2
      local effect3 = moduleInvetory.get_item_count("productivity-module-3") -- type 3

      local mult = effect1*4+effect2*6+effect3*10
      return mult/100+1
end

function AmountOfMachines(itemsPerSecond,output)
      if(itemsPerSecond) then
            return   itemsPerSecond/output

      end
end

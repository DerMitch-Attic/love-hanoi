--[[
    Towers of Hanoi
    ---------------

    Please note that this is the first time i've created a game.
    It contains bugs, it's ugly and inefficient - but works. :-)
]]

-- Font used for the title and moves counter
font_title = love.graphics.newFont(20)
-- Font used on the win screen
font_won = love.graphics.newFont(40)
-- Number of moves
moves = 0
-- Show debug information?
DEBUG = false

-- Stack of block of every (Please note: Indexes start by 1, not 0)
tower_blocks = {
    {5, 4, 3, 2, 1},
    {},
    {},
}
-- Condition to win, defaults to 54321 on the third stack
win_condition = table.concat(tower_blocks[1])
-- Did the player win the game?
game_won = false
-- Are we hovering over a tower?
tower_hover = nil
-- Has the player selected a tower?
tower_selected = nil
-- Width and height of a tower bar (@todo determine from image)
tower_width = 30
tower_height = 300
-- Coordinations of last click
mousePressX = nil
mousePressY = nil

show_invalid_move = false

-- Load images
function love.load()
    icon = love.graphics.newImage("img/icon.png")
    base = love.graphics.newImage("img/base.png")
    tower = love.graphics.newImage("img/tower.png")
    background = love.graphics.newImage("img/background.png")

    love.window.setTitle("Towers of Hanoi")
    love.window.setIcon(icon:getData())
end

--[[
    Game loop Update

    Does the following things:
    - Checks if the played is hovering over a tower
    - Checks if the played clicked somewhere
    - Handles stack movements
    - Checks win condition
]]
function love.update()
    -- If the player won the game, don't waste time calculating stuff
    if game_won then
        return
    end

    local mouseX, mouseY = love.mouse.getPosition()
    local width, height = love.graphics.getDimensions()

    -- Coordinates of the tower base (bar on the bottom)
    base_left = width / 2 - base:getWidth() / 2
    base_top = height - (width / 10) - base:getHeight()

    -- Calculate the bounding boxes of all 3 towers
    tower1x1 = width / 4 * 1 - tower_width * 2
    tower1y1 = base_top - tower_height + 20
    tower1x2 = tower1x1 + (tower_width * 4)
    tower1y2 = tower1y1 + tower_height

    tower2x1 = width / 4 * 2 - tower_width * 2
    tower2y1 = base_top - tower_height + 20
    tower2x2 = tower2x1 + (tower_width * 4)
    tower2y2 = tower2y1 + tower_height

    tower3x1 = width / 4 * 3 - tower_width * 2
    tower3y1 = base_top - tower_height + 20
    tower3x2 = tower3x1 + (tower_width * 4)
    tower3y2 = tower3y1 + tower_height

    -- If the cursor is within a click region, mark the tower as selected
    if (mouseX > tower1x1 and mouseY > tower1y1) and (mouseX < tower1x2 and mouseY < tower1y2) then
        tower_hover = 1
    elseif (mouseX > tower2x1 and mouseY > tower2y1) and (mouseX < tower2x2 and mouseY < tower2y2) then
        tower_hover = 2
    elseif (mouseX > tower3x1 and mouseY > tower3y1) and (mouseX < tower3x2 and mouseY < tower3y2) then
        tower_hover = 3
    else
        tower_hover = nil
    end

    -- If a click was registered since the last update, check if the player
    -- clicked on a tower region
    local clicked_tower = nil
    if mousePressX and mousePressY then
        mousePressX = nil
        mousePressY = nil
        show_invalid_move = false

        -- Check which tower was clicked if any
        if (mouseX > tower1x1 and mouseY > tower1y1) and (mouseX < tower1x2 and mouseY < tower1y2) then
            clicked_tower = 1
        elseif (mouseX > tower2x1 and mouseY > tower2y1) and (mouseX < tower2x2 and mouseY < tower2y2) then
            clicked_tower = 2
        elseif (mouseX > tower3x1 and mouseY > tower3y1) and (mouseX < tower3x2 and mouseY < tower3y2) then
            clicked_tower = 3
        else
            print("Click registered, but not on tower")
            return
        end

        if clicked_tower then
            -- If we click for the first time, just remember the tower
            -- else handle the block movement
            if not tower_selected then
                tower_selected = clicked_tower
            else
                blocks_selected = tower_blocks[tower_selected]
                blocks_clicked = tower_blocks[clicked_tower]

                -- Get the highest item from the stack and remove it
                block_to_move = table.remove(blocks_selected)

                if block_to_move == nil then
                    print("Block to move is nil, looks like a state bug")
                    return
                end

                -- Get the highest item from the next stack
                next_block = blocks_clicked[#blocks_clicked]

                if DEBUG then
                    print(" - Tables -")
                    print(table.concat(blocks_selected))
                    print(table.concat(blocks_clicked))
                end

                if next_block == nil or block_to_move < next_block then
                    -- Add block to the new stack
                    table.insert(blocks_clicked, block_to_move)
                else
                    -- Invalid move
                    print("Ignored illegal move ",
                            "block_to_move: ", block_to_move,
                            "next_block: ", next_block
                    )
                    table.insert(blocks_selected, block_to_move)
                    tower_selected = nil
                    show_invalid_move = true
                end

                -- Let the player select a new stack
                tower_selected = nil
                moves = moves + 1

                -- If the final stack matches the first initial stack, we win
                if table.concat(tower_blocks[3]) == win_condition then
                    game_won = true
                end
            end
        end -- end clicked_tower
    end -- end mouse clicked
end -- end update


-- Draw the block for a tower
-- tower_index: 1, 2 or 3
-- x, y: Initial coordinates for drawing (starting at the bottom of the tower)
function draw_blocks(tower_index, x, y)
    local my_blocks = tower_blocks[tower_index]
    local my_y = y - 5
    local block_height = 20
    -- Additional size for each block
    local block_width_factor = 20

    love.graphics.setColor(255, 0, 0)
    for _, block in pairs(my_blocks) do
        my_y = my_y - block_height
        love.graphics.rectangle("fill",
            x - block * (block_width_factor / 2),
            my_y + block, -- Add a slight space between blocks
            block * block_width_factor,
            block_height
        )
    end
end

-- Draw the game
function love.draw(dt)
    local width, height = love.graphics.getDimensions()

    -- Initialize
    love.graphics.setFont(font_title)
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(background, 0, 0)

    -- Status texts
    love.graphics.print("Towers of Hanoi", 30, 30)
    love.graphics.printf(moves .. " Moves", width - 130, 30, 100, "right")
    if DEBUG then
        love.graphics.printf(width .. "x" .. height, width - 110, height - 35, 100, "right")
    end

    if show_invalid_move then
        love.graphics.printf("Invalid move!", width / 2 - 100, height / 4, 200, "center")
    end

    -- Hurrah!
    if game_won then
        love.graphics.setFont(font_won)
        love.graphics.printf("Gewonnen!", width / 2 - 100, height / 2 - 40, 200, "center")
        return
    end

    if DEBUG then
        if tower_hover == 1 then
            love.graphics.print("Hover 1", 30, height - 55)
        elseif tower_hover == 2 then
            love.graphics.print("Hover 2", 30, height - 55)
        elseif tower_hover == 3 then
            love.graphics.print("Hover 3", 30, height - 55)
        else
            love.graphics.print("No Hover", 30, height - 55)
        end
        if tower_selected == 1 then
            love.graphics.print("Selected 1", 30, height - 35)
        elseif tower_selected == 2 then
            love.graphics.print("Selected 2", 30, height - 35)
        elseif tower_selected == 3 then
            love.graphics.print("Selected 3", 30, height - 35)
        else
            love.graphics.print("No selection", 30, height - 35)
        end
    end

    -- Tower base
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(base, base_left, base_top)

    -- Hover effect
    if tower_hover then
        love.graphics.setColor(0, 0, 0, 50)
        love.graphics.rectangle('fill',
            width / 4 * tower_hover - tower_width*2,
            base_top - tower_height + 20,
            tower_width * 4,
            tower_height
        )
    end

    -- Towers
    love.graphics.setColor(255, 255, 255) -- Do not remove or images get black
    love.graphics.draw(tower, width / 4 * 1 - (tower_width/2), base_top - tower_height + 20)
    love.graphics.draw(tower, width / 4 * 2 - (tower_width/2), base_top - tower_height + 20)
    love.graphics.draw(tower, width / 4 * 3 - (tower_width/2), base_top - tower_height + 20)

    -- Blocks for each tower
    draw_blocks(1, width / 4 * 1, base_top + 20)
    draw_blocks(2, width / 4 * 2, base_top + 20)
    draw_blocks(3, width / 4 * 3, base_top + 20)
end

-- If the mouse has been clicked, register the coordinates.
-- Actions will be triggered on love.update()
function love.mousereleased(x, y, button)
    mousePressX = x
    mousePressY = y
end

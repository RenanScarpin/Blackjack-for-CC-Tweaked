CARD_WIDTH = 8
CARD_HEIGHT = 8

local basalt = require("basalt")

-- Define card values and suits
local suits = {"Hearts", "Diamonds", "Clubs", "Spades"}
local values = {"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"}

-- Function to create a deck of cards
local function createDeck()
    local deck = {}
    for _, suit in ipairs(suits) do
        for _, value in ipairs(values) do
            table.insert(deck, {value = value, suit = suit})
        end
    end
    return deck
end

-- Function to shuffle the deck
local function shuffleDeck(deck)
    for i = #deck, 2, -1 do
        local j = math.random(i)
        deck[i], deck[j] = deck[j], deck[i]
    end
end

-- Function to draw a card from the deck
local function drawCard(deck)
    return table.remove(deck, 1)
end

-- Function to calculate the value of a hand
local function calculateHandValue(hand)
    local value = 0
    local aces = 0
    for _, card in ipairs(hand) do
        if card.value == "J" or card.value == "Q" or card.value == "K" then
            value = value + 10
        elseif card.value == "A" then
            value = value + 11
            aces = aces + 1
        else
            value = value + tonumber(card.value)
        end
    end
    while value > 21 and aces > 0 do
        value = value - 10
        aces = aces - 1
    end
    return value
end

local function moveable_card(Frame, card)
    local movCard = Frame
        :addMovableFrame()
        :setSize(CARD_WIDTH, CARD_HEIGHT)
        :setPosition(0, 2)
    local lb1 = movCard
        :addLabel()
        :setText(card.value .. " of")
    local lb2 = movCard
        :addLabel()
        :setPosition(0, 1, true)
        :setText(card.suit)
    return movCard
end

local function takeBet(bet)
    local remaining = bet
    while true do
        for i = 1, 16, 1 do
            turtle.select(i)
            if(turtle.getItemCount() > 0 and turtle.getItemDetail().name == "minecraft:diamond") then
                local count = turtle.getItemCount()
                if(count >= remaining) then
                    turtle.dropDown(remaining)
                    return
                else
                    turtle.dropDown(count)
                    remaining = remaining - count
                end
            end
        end
    end
end

math.randomseed()

local function playGame()
local bet = 0 --placeHolder

local main = basalt.createFrame()

local pTurn = main:addFrame():setPosition(1, 1):setSize("parent.w", "parent.h"):setBackground(colors.lightGray):hide()

local betting = main:addFrame():setPosition(1, 1):setSize("parent.w", "parent.h"):setBackground(colors.gray)
local betLabel = betting:addLabel()
    :setText("Insert your bet!")
    :setForeground(colors.white)
    :setBackground(colors.gray)
    :setFontSize(1)
    :setPosition(12, 2)
local betInput = betting:addInput()
    :setPosition(14, 7)
    :setBackground(colors.white)
    :setForeground(colors.black)
	:setInputType("number")
    :onChar(function (self, event, char)
        if(char=="-")then
          return false
        end
      end)
    
local betConfirm = betting:addButton()
    :setText("Confirm")
    :setPosition(14, 10)
    :setBackground(colors.white)
    :setForeground(colors.black)
    :onClick(function(self, event, button, x, y)
        if(button == 1) then
            if(type(betInput:getValue()) == type(bet)) then
            bet = betInput:getValue()
            takeBet(bet)
            betting:hide()
            pTurn:show()
            end
        end
    end
    )

local dTurn = main:addFrame():setPosition(1, 2):setSize("parent.w", "parent.h - 1"):setBackground(colors.lightGray):hide()
local bust = main:addFrame():setPosition(1, 2):setSize("parent.w", "parent.h - 3"):setBackground(colors.red):hide()
local bLabel = bust
    :addLabel()
    :setText("Bust!")
    :setForeground(colors.white)
    :setBackground(colors.red)
    :setFontSize(2)
    :setPosition(10, 5)
local victory = main:addFrame():setPosition(1, 3):setSize("parent.w", "parent.h - 4"):setBackground(colors.green):hide()
local vLabel = victory
    :addLabel()
    :setText("Victory!")
    :setForeground(colors.white)
    :setBackground(colors.green)
    :setFontSize(2)
    :setPosition(10, 5)
local failure = main:addFrame():setPosition(1, 3):setSize("parent.w", "parent.h - 4"):setBackground(colors.red):hide()
local fLabel = failure
    :addLabel()
    :setText("Dealer won!")
    :setForeground(colors.white)
    :setBackground(colors.red)
    :setFontSize(2)
    :setPosition(6, 5)
local tie = main:addFrame():setPosition(1, 3):setSize("parent.w", "parent.h - 4"):setBackground(colors.white):hide()
local tLabel = tie
    :addLabel()
    :setText("Tie!")
    :setForeground(colors.black)
    :setBackground(colors.white)
    :setFontSize(2)
    :setPosition(6, 5)

-- Create and shuffle the deck
local deck = createDeck()
shuffleDeck(deck)

-- set up player`s hand
local c1 = drawCard(deck)
local c2 = drawCard(deck)
local playerHand = {c1, c2}
moveable_card(pTurn, c1):animatePosition(1, 2, 1)
moveable_card(pTurn, c2):animatePosition(CARD_WIDTH + 1, 2, 1)


local pHandDisplay = pTurn
    :addLabel("pHandDisplay")
    :setBackground(colors.white)
    :setText("Player`s hand value = " .. calculateHandValue(playerHand))
    :setFontSize(1)

local standButton = pTurn --> Basalt returns an instance of the object on most methods, to make use of "call-chaining"
    :addButton("standButton") --> This is an example of call chaining
    :setPosition(28, 11)
    :setBorder(colors.lightBlue)
    :setText("Stand")
    :onClick(function(self, event, button, x, y)
            if(button == 1) then
                dTurn:show()
            end
        end
        )

local hitButton = pTurn
    :addButton("hitButton")
    :setPosition(14, 11)
    :setBorder(colors.lightBlue)
    :setText("Hit!")
    :onClick(function(self, event, button, x, y)
        if(button == 1) then
            local card = drawCard(deck)
            table.insert(playerHand, card)
            pHandDisplay:setText("Player`s hand value = " .. calculateHandValue(playerHand))
            moveable_card(pTurn, card):animatePosition(CARD_WIDTH * 2, 2, 1)
            if (calculateHandValue(playerHand) == 21) then
                dTurn:show()
            elseif (calculateHandValue(playerHand) > 21) then
                dTurn:show()
                bust:show():setVisible(true)
            end
        end
    end
    )

local dFirstCard = drawCard(deck)
local dSecondCard = drawCard(deck)
local dealerHand = {dFirstCard, dSecondCard}
moveable_card(dTurn, dFirstCard):animatePosition(1, 2, 1)
moveable_card(dTurn, dSecondCard):animatePosition(CARD_WIDTH + 1, 2, 1)

local dHandDisplay = dTurn
    :addLabel("pHandDisplay")
    :setPosition(16, 1)
    :setBackground(colors.white)
    :setText("Dealer`s hand value = " .. calculateHandValue(dealerHand))
    :setFontSize(1)

local dNext = dTurn
    :addButton("dNext")
    :setPosition(14, 11)
    :setText("Next")
    :onClick(function(self, event, button, x, y)
        if(button == 1) then
            if(victory:isVisible() or tie:isVisible() or bust:isVisible() or failure:isVisible()) then
                --How the fuck do I reset this
            elseif(calculateHandValue(dealerHand) > 21) then
                victory:show()
                turtle.suckDown(bet * 2)
            elseif(calculateHandValue(playerHand) > calculateHandValue(dealerHand)) then
                local card = drawCard(deck)
                table.insert(dealerHand, card)
                dHandDisplay:setText("Dealer`s hand value = " .. calculateHandValue(dealerHand))
                moveable_card(dTurn, card):animatePosition(CARD_WIDTH * 2, 2, 1)
            elseif (calculateHandValue(dealerHand) == calculateHandValue(playerHand)) then
                tie:show()
                turtle.suckDown(bet)
            else
                failure:show()
            end
        end
    end
    )

basalt.autoUpdate()
end

playGame()
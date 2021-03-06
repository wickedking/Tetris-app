-----------------------------------------------------------------------------------------
--
-- main.lua
-- Made by WickedKing1392 and ElementBox
-----------------------------------------------------------------------------------------
--Redo menu background screen
--Settings screen buttons
--app icons
--realign all buttons in game
--fix display scaling for backgrounds then test on device for anything else
--new image for fail screen game over
--allign background to brick floor
--allign brick floor to freeze point on board
--Redo minus button for fill board number
--potentially fix lines not being removed

--reduce app size?


highScores = require("highScore")

--Implement better garbage collection
timer.performWithDelay(1, function() collectgarbage("collect") end)

--The music options. 
options = {loop = -1}

--Global variable for filling the board.
fillBoard = 0

--Global variable used for if sound effects are to be used.
soundEffects = true

--Global table used to switch and hold the different audio files.
sfx = {}
sfx.theme = audio.loadStream("theme.mp3")
sfx.level_one = audio.loadStream("level_one.mp3")
sfx.level_two = audio.loadStream("level_two.mp3")
sfx.level_three = audio.loadStream("level_three.mp3")
sfx.level_four = audio.loadStream("level_four.mp3")

--Global variable for if music is to be used.
music = true

--Global table for the background.
background = {}

--The current level.
level = 1

--Global variable for if control is tapping or buttons.
tapControl = true

--Counter for the number of frames that have passed since the start.
update = 0
--The number of frames need to pass to force the piece down.
update_number = 20
--The score amount needed to reach the next level.
updatePieceNumber = 100

--Reference to the current falling piece.
currentPiece = {}
--The next piece to create
index = 4
--Used to stop new pieces from being created
pieceCreate = true
--The reference to the board
board = {}
--Used to allow pieces to be rotated.
canRotate = true
--Flag if the game is paused
pause = false
--The group that holds all the drawn pieces.
group = {}
--The group that holds a reference to all the extra stuff on the screen.
extra_group = {}
--Used to replay the game or to exit
start_over = true
--Holds a reference to all the items when the game fails
gameOverGroup = {}
--The score
totalScore = 0
--Internal copy of the score used to calculate the next level
totalScoreCopy = 0
--A reference to the score display items
scoreGroup = display.newGroup()
--A reference to the next piece display items
nextPieceGroup = display.newGroup()

--A reference to the lines display items
pieceLines = display.newGroup()

--A flag for using the ghost piece or not
use_ghostPiece = true
--A reference to the ghost piece display items.
ghostGroup = nil

--Used to change range of random colors
low_color = 50
high_color = 51

--Constants for the printing on screen. The offset for each
x_offset = 10
y_offset = -12

--the multiplier for the board values.
board_offset = 21 --need to be set at run time
height_offset = display.contentHeight / 23

--The constants for the board dimensions.
board_height = 23
board_width = 10

--A constants for printing the block sizes
block_size = 19

--A block used to block the screen when paused
pause_block = display.newRect(0,0,0,0)
--A reference to the text when paused
pause_text = {}

--The reference to the sound effect.
click = audio.loadSound("tap4.wav")

--References to the individual blocks of the current piece.
display1 = display.newRect(0,0,0,0)
display2 = display.newRect(0,0,0,0)
display3 = display.newRect(0,0,0,0)
display4 = display.newRect(0,0,0,0)

--References to the menu and listeners.
local menuScreen = {}
local tweenMS = {}
settingsScreenGroup = {}

--Actual references to the lines for the pieces
line1 = display.newRect(0,0,0,0)
line2 = display.newRect(0,0,0,0)

--References to the settings buttons
soundEffectImage = {}
musicImage = {}
controlImage = {}

--References to the text for the scores when failed.
highScoreText = {}
yourScoreText = {}

--References to the highscore table, score and file.
highScore = {}
highScore.score1 = 100
highScore = loadTable("highScore.json")

fillTextNumber = display.newRect(0,0,0,0)

pauseGroup = display.newGroup()

useLines = true

ghostImage = display.newRect(0, 0, 0, 0)
lineImage = display.newRect(0, 0, 0, 0)

--if highScore.score1 == 100 then -- highScore.score1 == nil then
--	highScore.score1 = 1500
--	saveTable(highScore, "highScore.json")
--end

--Used to populate the settingsScreen with all the buttons, listeners and text.
function settingsScreen()
	--TODO add controls for the pieceLines and ghostPiece

	menuScreen:removeSelf()
	audio.stop()
	settingScreenGroup = display.newGroup()
	fillTextNumber:removeSelf()
	
	local fillText = display.newText(settingScreenGroup, "Fill Board", display.contentWidth/5, display.contentHeight/6, native.systemFontBold, 16)
	local soundEffectText = display.newText(settingScreenGroup, "Sound Effects", display.contentWidth/5, display.contentHeight/6 * 2, native.systemFontBold, 16)
	local musicText = display.newText(settingScreenGroup, "Music", display.contentWidth/5, display.contentHeight/6 * 3, native.systemFontBold, 16)
	local controlText = display.newText(settingScreenGroup, "Control:", display.contentWidth/5, display.contentHeight/6 * 4- 6, native.systemFontBold, 16)
	local controlText2 = display.newText(settingScreenGroup, "On for Tap", display.contentWidth/5, display.contentHeight/6 * 4 + 11, native.systemFontBold, 16)
	
	
	local backText = display.newText(settingScreenGroup, "Main Menu", display.contentWidth/2, display.contentHeight/6 * 5, native.systemFontBold, 16)
	
	local fillMinus = display.newImage("minus.png")
	local fillPlus = display.newImage("plus.png")
	settingScreenGroup:insert(fillMinus)
	settingScreenGroup:insert(fillPlus)
	fillTextNumber = display.newText(fillBoard, display.contentWidth/4 * 3, display.contentHeight/6, native.systemFontBold, 16)
	
	fillMinus.x = display.contentWidth/4 * 3 - 30
	fillPlus.x = display.contentWidth/4 * 3 + 30
	fillMinus.y = display.contentHeight/6 +7
	fillPlus.y = display.contentHeight/6
	fillMinus.width = 50
	fillMinus.height = 50
	fillPlus.width = 30
	fillPlus.height = 30
	
	fillMinus:addEventListener("tap", minusFill)
	fillPlus:addEventListener("tap", addFill)
	
	if soundEffects == true then
		soundEffectImage = display.newImage("on_button.png")
	else 
		soundEffectImage = display.newImage("off_button.png")
	end
	if music == true then
		musicImage = display.newImage("on_button.png")
	else 
		musicImage = display.newImage("off_button.png")
	end
	if tapControl == true then
		controlImage = display.newImage("on_button.png")
	else 
		controlImage = display.newImage("off_button.png")
	end
	
	--Scaling for the current image
	soundEffectImage:scale(0.5, 0.5)
	musicImage:scale(0.5, 0.5)
	controlImage:scale(0.5, 0.5)
	
	-- The x values of the buttons
	soundEffectImage.x = display.contentWidth/4 * 3
	musicImage.x = display.contentWidth/4 * 3
	controlImage.x = display.contentWidth/4 * 3
	
	--The y values of the buttons
	soundEffectImage.y = display.contentHeight/6 * 2
	musicImage.y = display.contentHeight/6 * 3
	controlImage.y = display.contentHeight/6 * 4
	
	--The event listeners for the buttons	
	soundEffectImage:addEventListener("tap", soundEffect)
	musicImage:addEventListener("tap", soundMusic)
	controlImage:addEventListener("tap", displayControl)	
	backText:addEventListener("tap", backToMenu)
	
end

--Listener method used to remove the settings Screen and go back to main menu.
function backToMenu()
	--Remove all buttons and text and recreate menu Screen.
	settingScreenGroup:removeSelf()
	settingScreenGroup = display.newGroup()
	
	soundEffectImage:removeSelf()
	musicImage:removeSelf()
	controlImage:removeSelf()
	
	--Used to keep a blank reference, to keep other code from removing nil references.
	soundEffectImage = display.newRect(0,0,0,0)
	musicImage = display.newRect(0,0,0,0)
	controlImage = display.newRect(0,0,0,0)
	
	addMenuScreen()

end



--Listener method to switch between using the ghost piece or not.
function ghostPieceSwitch()
  if use_ghostPiece == true then
    use_ghostPiece = false
    
    if ghost1 ~= 1 then
      ghost1:removeSelf()
      ghost2:removeSelf()
      ghost3:removeSelf()
      ghost4:removeSelf()
    end
    ghost1 = 1
    ghost2 = 1
    ghost3 = 1
    ghost4 = 1
    
    ghostImage = display.newImage("off_button.png")
    ghostImage:scale(0.5, 0.5)
    ghostImage.x = display.contentWidth / 4 * 3
    ghostImage.y = display.contentHeight / 3
    pauseGroup:insert(ghostImage)
  else
    use_ghostPiece = true
    ghostImage = display.newImage("on_button.png")
    ghostImage:scale(0.5, 0.5)
    ghostImage.x = display.contentWidth / 4 * 3
    ghostImage.y = display.contentHeight / 3
    pauseGroup:insert(ghostImage)
  end
end

--Listener method to switch between displaying the piece lines or not.
function lineSwitch()
  if useLines == true then
    useLines = false
    lineImage = display.newImage("off_button.png")
    lineImage:scale(0.5, 0.5)
    lineImage.x = display.contentWidth / 4 * 3
    lineImage.y = display.contentHeight / 4
    pauseGroup:insert(lineImage)
  else
    useLines = true
    lineImage = display.newImage("on_button.png")
    lineImage:scale(0.5, 0.5)
    lineImage.x = display.contentWidth / 4 * 3
    lineImage.y = display.contentHeight / 4
    pauseGroup:insert(lineImage)
  end
end

--Listener method used to pause and unpause the game. Stops the pieces from moving and blocks the screen.
function pauseGame()
	if pause == false then
		pause = true
		audio.pause()
    pauseGroup = display.newGroup()
    
		pause_block = display.newRect(0,0,1000, 1000)
		pause_block:setFillColor(0,0,0)
		
    pauseGroup:insert(pause_block)
    
    local backText = display.newText("Back", display.contentWidth / 2 , display.contentHeight / 2, native.systemFontBold, 18)
    local useLineText = display.newText("Display lines:", display.contentWidth / 4 , display.contentHeight / 4, native.systemFontBold, 16)
    local useGhostText = display.newText("Display Ghost Piece:", display.contentWidth / 4 , display.contentHeight / 3,  native.systemFontBold, 16)
    pauseText = display.newText("PAUSED", display.contentWidth/2, display.contentHeight/8, native.systemFontBold, 18)
    
    pauseGroup:insert(useLineText)
    pauseGroup:insert(useGhostText)
    pauseGroup:insert(backText)
    
    backText:addEventListener("tap", pauseGame)
        
    if use_ghostPiece == true then
      ghostImage = display.newImage("on_button.png")
    else
      ghostImage = display.newImage("off_button.png")
    end
    
    if useLines == true then
      lineImage = display.newImage("on_button.png")
    else
      lineImage = display.newImage("off_button.png")
    end
  
    ghostImage:scale(0.5, 0.5)
    lineImage:scale(0.5, 0.5)
  
    ghostImage.x = display.contentWidth / 4 * 3
    lineImage.x = display.contentWidth / 4 * 3
    
    ghostImage.y = display.contentHeight / 3
    lineImage.y = display.contentHeight / 4
    
    ghostImage:addEventListener("tap", ghostPieceSwitch)
    lineImage:addEventListener("tap", lineSwitch)
    
    pauseGroup:insert(ghostImage)
    pauseGroup:insert(lineImage)
     
	else
		pause = false
		audio.resume()
		pause_block:removeSelf()
		pauseText:removeSelf()
    --ghostImage:removeEventListener("tap", ghostPieceSwitch)
    --lineImage:removeEventListener("tap", lineSwitch)
    pauseGroup:removeSelf()
	end
end


--Used to randomize the color of all the blocks currently on the board.
function randomizeColor()
	for i = 0, board_height do
		for j = 0, board_width do
			if board[i][j] ~= 0 then
				board[i][j]:setFillColor(math.random(low_color, high_color) / 100 ,math.random(low_color, high_color) / 100, math.random(low_color, high_color) / 100)
			end
		end
	end
end


--Deletes the references to all the blocks in the board to all deletion of blocks.
function deleteBoard()
	for i =0, board_height do
		for j = 0, board_width do
			board[i][j] = 0
		end
	end
end


--Used to draw the currentPiece thats falling.
function drawPiece(the_pieces)
	pieceLines:removeSelf()
	if currentPiece == nil then
		return
	end
	if currentPiece.y == nil then
		return
	end
	--Mapping the actual location to the board locations.
	local i = math.floor(currentPiece.y/height_offset)
	local j = math.floor(currentPiece.x/board_offset)

	if display1 ~= nil then
		display1:removeSelf()
		display2:removeSelf()
		display3:removeSelf()
		display4:removeSelf()
	end
	
	local small_x = 10
	local big_x = -10
	
	--calculates the smallest and biggest x offsets of the piece.
	if the_pieces.piece1x < small_x then
		small_x = the_pieces.piece1x
	end
	if the_pieces.piece2x < small_x then
		small_x = the_pieces.piece2x
	end
	if the_pieces.piece3x < small_x then
		small_x = the_pieces.piece3x
	end
	if the_pieces.piece4x < small_x then
		small_x = the_pieces.piece4x
	end
	if the_pieces.piece1x > big_x then
		big_x = the_pieces.piece1x
	end
	if the_pieces.piece2x > big_x then
		big_x = the_pieces.piece2x
	end
	if the_pieces.piece3x > big_x then
		big_x = the_pieces.piece3x
	end
	if the_pieces.piece4x > big_x then
		big_x = the_pieces.piece4x
	end
	

	pieceLines = display.newGroup()
	
	small_x = (small_x * 21) + currentPiece.x
	big_x = big_x + 1
	big_x = (big_x * 21) + currentPiece.x
	
	--line1:removeSelf()
	--line2:removeSelf()
	
	--Displays the lines off the currentPiece
  
  if useLines == true then
    local line1 = display.newLine(small_x , currentPiece.y - 35, small_x, 480)
    local line2 = display.newLine(big_x, currentPiece.y - 35, big_x, 480)
	
    pieceLines:insert(line1)
    pieceLines:insert(line2)
	
    line1:setStrokeColor(0.33,0.0,1.0)
    line2:setStrokeColor(0.33,0.0,1.0)
  end
	
	--Draws the piece on the screen
	display1 = display.newRect((j + the_pieces.piece1x) * board_offset + x_offset, (i + the_pieces.piece1y) * board_offset + y_offset, block_size, block_size)
	display2 = display.newRect((j + the_pieces.piece2x) * board_offset + x_offset, (i + the_pieces.piece2y) * board_offset + y_offset, block_size, block_size)
	display3 = display.newRect((j + the_pieces.piece3x) * board_offset + x_offset, (i + the_pieces.piece3y) * board_offset + y_offset, block_size, block_size)
	display4 = display.newRect((j + the_pieces.piece4x) * board_offset + x_offset, (i + the_pieces.piece4y) * board_offset + y_offset, block_size, block_size)

	group:insert(display1)
	group:insert(display2)
	group:insert(display3)
	group:insert(display4)
	
	if use_ghostPiece and pause == false then
		ghostPiece()
	end
end


--Draws the next piece to be created, in the corner.
function drawNextPiece()
	if pause == true then
		return
	end
	nextPieceGroup:removeSelf()
	nextPieceGroup = display.newGroup()
	local nextPiece = {}
	local type = {}
	
	--Switch to calculate the next pieces.
	if index == 0 then
		type = "tPiece"
	elseif index == 1 then
		type = "zPiece"
	elseif index == 2 then
		type = "sPiece"
	elseif index == 3 then
		type = "oPiece"
	elseif index == 4 then
		type = "iPiece"
	elseif index == 5 then
		type = "lPiece"
	elseif index == 6 then
		type = "jPiece"
	end
	
	--Offsets
	local i = 20
	local j = 13
	
	nextPiece["rotation"] = 0
	nextPiece["type"] = type
	local the_pieces = pieceRotation(nextPiece)
	
	local displayNext1 = display.newRect((j + the_pieces.piece1x) * board_offset + x_offset, (i + the_pieces.piece1y) * board_offset + y_offset + 30 , block_size, block_size)
	local displayNext2 = display.newRect((j + the_pieces.piece2x) * board_offset + x_offset, (i + the_pieces.piece2y) * board_offset + y_offset + 30 , block_size, block_size)
	local displayNext3 = display.newRect((j + the_pieces.piece3x) * board_offset + x_offset, (i + the_pieces.piece3y) * board_offset + y_offset + 30 , block_size, block_size)
	local displayNext4 = display.newRect((j + the_pieces.piece4x) * board_offset + x_offset, (i + the_pieces.piece4y) * board_offset + y_offset + 30 , block_size, block_size)
	
	nextPieceGroup:insert(displayNext1)
	nextPieceGroup:insert(displayNext2)
	nextPieceGroup:insert(displayNext3)
	nextPieceGroup:insert(displayNext4)
	
	
end


--Used to update the score and change levels
function updateScore(rows)
	if pause == true then
		return
	end
	scoreGroup:removeSelf()
	totalScoreCopy = totalScoreCopy + (rows * 100)
	totalScore = totalScore + (rows * 100)
	scoreGroup = display.newGroup()
	local scoreBox = display.newRect(display.contentWidth - 50 , (display.contentHeight/5) * 3 + 60, 50, 50)
	scoreBox:setFillColor(1,1,1)
	scoreGroup:insert(scoreBox)
	local text = display.newText(totalScore, display.contentWidth - 50, (display.contentHeight / 5) * 3 + 60, native.systemFontBold, 14)
	text:setFillColor(0,0,0)
	scoreGroup:insert(text)
	--If user has reached enough points for the next level
	--print(level)
	if totalScoreCopy >= updatePieceNumber then
		print("update level")
		print("totalScoreCopy = "..totalScoreCopy)
		print(totalScore)
		--if update_number < 3 then
		--	return
		--end
		level = level + 1
		print(level)
		totalScoreCopy = totalScoreCopy % updatePieceNumber
		if (level % 4 == 2) then 
			if update_number > 2 then
				update_number = update_number - 2
			end
			audio.stop()
			--audio.dispose(sfx.level_one)
			audio.play(sfx.level_two, options)
			background:removeSelf()
			background = display.newImage("spring2.png", display.contentWidth/2, display.contentHeight/2)
			background.width = display.contentWidth
			background.height = display.contentHeight
			background:toBack()
		elseif (level % 4 == 3) then
			if update_number > 2 then
				update_number = update_number - 2
			end
			audio.stop()
			--audio.dispose(sfx.level_two)
			audio.play(sfx.level_three, options)
			background:removeSelf()
			background = display.newImage("summer2.png", display.contentWidth/2, display.contentHeight/2)
			background.width = display.contentWidth
			background.height = display.contentHeight	
			background:toBack()		
		elseif(level % 4 == 0) then
			if update_number > 2 then
				update_number = update_number - 2
			end
			audio.stop()
			--audio.dispose(sfx.level_three)
			audio.play(sfx.level_four, options)
			background:removeSelf()
			background = display.newImage("fall2.png", display.contentWidth/2, display.contentHeight/2)
			background.width = display.contentWidth
			background.height = display.contentHeight
			background:toBack()
		else
			if update_number > 2 then
				update_number = update_number - 2
			end
			print(1)
			audio.stop()
			print(2)
			--audio.dispose(sfx.level_four)
			print(3)
			audio.play(sfx.level_one, options)
			print(4)
			background:removeSelf()
			print(5)
			background = display.newImage("winter2.png", display.contentWidth/2, display.contentHeight/2)
			print(6)
			background.width = display.contentWidth
			print(7)
			background.height = display.contentHeight
			print(8)
			background:toBack()
			print(9)
		
		end
	end
end


--Creates the table that is the board.
function createBoard()
	for i = 0, board_height do
	board[i] = {}
		for j = 0, board_width do
		board[i][j] = 0
		end
	end
end


--Increment the fillBoard number
function addFill()
	if fillBoard >= 5 then
		return
	end
	fillBoard = fillBoard + 1
	fillTextNumber:removeSelf()
	fillTextNumber = display.newText(fillBoard, display.contentWidth/4 * 3, display.contentHeight/6, native.systemFontBold, 16)
end


--decrement the fillBoard number
function minusFill()
	if fillBoard <= 0 then
		return
	end
	fillBoard = fillBoard - 1
	fillTextNumber:removeSelf()
	fillTextNumber = display.newText(fillBoard, display.contentWidth/4 * 3, display.contentHeight/6, native.systemFontBold, 16)
end


--Listener method used to change if sound effects are to be used.
function soundEffect()
	if soundEffects then
		soundEffects = false
		soundEffectImage:removeSelf()
		soundEffectImage = display.newImage("off_button.png")
		soundEffectImage.x = display.contentWidth/4 * 3
		soundEffectImage.y = display.contentHeight/6 * 2
		soundEffectImage:scale(0.5, 0.5)
		soundEffectImage:addEventListener("tap", soundEffect)
	else
		soundEffects = true
		soundEffectImage:removeSelf()
		soundEffectImage = display.newImage("on_button.png")
		soundEffectImage.x = display.contentWidth/4 * 3
		soundEffectImage.y = display.contentHeight/6 * 2
		soundEffectImage:scale(0.5, 0.5)
		soundEffectImage:addEventListener("tap", soundEffect)
	end
end


--Listener method used to change if music is to be used.
function soundMusic()
	if music then
		music = false
		musicImage:removeSelf()
		musicImage = display.newImage("off_button.png")
		musicImage.x = display.contentWidth/4 * 3
		musicImage.y = display.contentHeight/6 * 3
		musicImage:scale(0.5, 0.5)
		musicImage:addEventListener("tap", soundMusic)
	else
		music = true
		musicImage:removeSelf()
		musicImage = display.newImage("on_button.png")
		musicImage.x = display.contentWidth/4 * 3
		musicImage.y = display.contentHeight/6 * 3
		musicImage:scale(0.5, 0.5)
		musicImage:addEventListener("tap", soundMusic)
	end
end


--Listener method used to change the control method from tapping to buttons.
function displayControl()
	if tapControl then
		tapControl = false
		controlImage:removeSelf()
		controlImage = display.newImage("off_button.png")
		controlImage.x = display.contentWidth/4 * 3
		controlImage.y = display.contentHeight/6 * 4
		controlImage:scale(0.5, 0.5)
		controlImage:addEventListener("tap", displayControl)
		
	else
		tapControl = true
		controlImage:removeSelf()
		controlImage = display.newImage("on_button.png")
		controlImage.x = display.contentWidth/4 * 3
		controlImage.y = display.contentHeight/6 * 4
		controlImage:scale(0.5, 0.5)
		controlImage:addEventListener("tap", displayControl)
	end

end


--Creates the main menu screen.
function addMenuScreen()
	menuScreen = display.newGroup()
	local mScreen = display.newImage("splash_other.png")
	mScreen:toBack()
	local startButton = display.newText("Play Game", display.contentWidth/5, display.contentHeight/4 * 3.7,  native.systemFontBold, 20)
	-- display.newImage("start4.png")
	--startButton:scale( 0.65, 0.65)
	
	local settingsButton = display.newText("Settings", display.contentWidth/4 * 3.25, display.contentHeight/4 * 3.70, native.systemFontBold, 20)
	-- display.newImage("settings.png")
	--settingsButton:scale(0.08, 0.08)
	--settingsButton.x = display.contentWidth/4 * 3.25
	--settingsButton.y = display.contentHeight/4 * 3.70
	settingsButton:addEventListener("tap", settingsScreen)
	
	mScreen.x = display.contentWidth/2 
	mScreen.y = display.contentHeight/2
	menuScreen:insert(mScreen)
	menuScreen:insert(startButton)
	menuScreen:insert(settingsButton)
	
	startButton.name = 'startB'
	--startButton.x = display.contentWidth/5
	--startButton.y = display.contentHeight/4 * 3.6 + 8
	startButton:addEventListener('tap', tweenMS)
	
	if music then 
		audio.play(sfx.theme, options)
	end

end


--Listener method used to transition from the main menu to the game.
function tweenMS:tap(e)
	if (e.target.name == 'startB') then
		transition.to(menuScreen, {time = 400, y = -menuScreen.height * 2, transition = easing.outExpo, onComplete = addGameScreen})
		audio.stop()
		create()
	end
end


--function used to exit after a second.
function empty()
	timer.performWithDelay(1000,os.exit())
end


--Listener method used to kill the app.
function goAway()
	audio.stop()
	foreground = display.newImage("thank-you.png", display.contentWidth/2, display.contentHeight/2)
	foreground.width = display.contentWidth
	foreground.height = display.contentHeight
	
	foreground:toFront()
	--timer.performWithDelay(10000, os.exit())
	timer.performWithDelay(1000, empty, 1)
end


--Listener method used to restart the game
function recreate()
	gameOverGroup:removeSelf()
	timer.performWithDelay(1000, create, 1)
	nextPieceGroup = display.newGroup()
end


--Used to stop the game when the user fails.
function fail()
	if start_over then
		background:removeSelf()
		deleteBoard()
		board = {}
		pieceCreate = false
		gameOverGroup = display.newGroup()
		start_over = false
		pause = true
		
		extra_group:removeSelf()
		
		Runtime:removeEventListener("enterFrame", movePiece)

		local yes = display.newImage("yes.png")
		yes.x = display.contentWidth/4
		yes.y = (display.contentHeight/4) * 3
		--yes:scale(0.4, 0.4)
		local no = display.newImage("no.png")
		--no:scale(0.5, 0.5)
		no.x = (display.contentWidth/4) * 3
		no.y = (display.contentHeight/4) * 3
		no.width = 140
		no.height = 100
		
		local failed = display.newImage("fail.png")
		
		failed.x = display.contentWidth/2
		failed.y = display.contentHeight/4
		failed.name = "failed"
		
		yes.name = "yes"
		no.nmae = "no"
		
		gameOverGroup:insert(yes)
		gameOverGroup:insert(no)
		gameOverGroup:insert(failed)
		
		yes:addEventListener('tap', recreate)
		no:addEventListener('tap', goAway)
		no:addEventListener('tap', goAway)
		group:removeSelf()
		if nextPieceGroup ~= nil then
			nextPieceGroup:removeSelf()
		end
		scoreGroup:removeSelf()
		ghostGroup:removeSelf()
		--line1:removeSelf()
		--line2:removeSelf()
		pieceLines:removeSelf()
		pieceLines = display.newGroup()
		ghostGroup = display.newGroup()
		
		--if totalScore > highScore.score1 then
		--	highScore.score1 = totalScore
		--	saveTable(highScore, "highScore.json")
		--	display.newText(gameOverGroup, "NEW HIGHSCORE!", display.contentWidth/2, display.contentHeight/2 + 30, native.systemFontBold, 16)
		--end
	
		--highScoreText = display.newText(gameOverGroup, "High Score: "..highScore.score1, display.contentWidth/5 * 2- 30, display.contentHeight/2, native.systemFontBold, 14)
		--highScoreText:setFillColor(0,0,0)
		
		yourScoreText = display.newText(gameOverGroup, "Your Score: "..totalScore, display.contentWidth/5 * 4 - 35, display.contentHeight/2, native.systemFontBold, 14)
		yourScoreText:setFillColor(0,0,0)
		
	end
end


--Used to create the currentPiece
function createPiece()
	updateScore(0)
	canRotate = true
	pieceCreate = true
	
	local balloon = display.newImage("base.png")
	balloon.width = 21
	balloon.height = 21
	balloon:scale(0,0)
	
	local balloon = display.newGroup()
	if index == 0 then
		balloon.type = "tPiece"
	elseif index == 1 then
		balloon.type = "zPiece"
	elseif index == 2 then
		balloon.type = "sPiece"
	elseif index == 3 then
		balloon.type = "oPiece"
	elseif index == 4 then
		balloon.type = "iPiece"
	elseif index == 5 then
		balloon.type = "lPiece"
	elseif index == 6 then
		balloon.type = "jPiece"
	end

	balloon.height = 21
	balloon.width = 21
	balloon:scale(.3, .3)
	balloon.myName = "Square"
	balloon.x = 21 * 5
	balloon.y = -50
	
	currentPiece = balloon
	balloon.isFixedRotation = true
	index = math.random(0,6)
	drawNextPiece()
end


--Used to make the board match the screen.
function updateBoard(the_pieces)
--will be called will freezeing piece
--will create new objects on board and then display.
--will be able to keep a reference to all "destroyed" pieces
--will check rows to see if deletion is necassary
	if pause == false then

		i = math.floor(currentPiece.y/board_offset)
		j = math.floor(currentPiece.x/board_offset)
		
		--well checks are actually working at the moment. 

		if i + the_pieces.piece1y > board_height or j + the_pieces.piece1x > board_width or j + the_pieces.piece1x < 0 or i + the_pieces.piece1y < 0 then
			pause = true
			fail()
			return
		else
			board[i + the_pieces.piece1y][j + the_pieces.piece1x] = display.newRect((j + the_pieces.piece1x)* board_offset + x_offset, (i + the_pieces.piece1y)*board_offset + y_offset, block_size, block_size)
			board[i + the_pieces.piece1y][j + the_pieces.piece1x]:setFillColor(math.random(low_color, high_color) / 100 ,math.random(low_color, high_color) / 100, math.random(low_color, high_color) / 100)
			group:insert(board[i + the_pieces.piece1y][j + the_pieces.piece1x])
			--physics.addBody(board[i + the_pieces.piece1y][j + the_pieces.piece1x], "kinematic")
		end
		
		if i + the_pieces.piece2y > board_height or j + the_pieces.piece2x > board_width or j + the_pieces.piece2x < 0 or i + the_pieces.piece2y < 0 then
			pause = true
			fail()
			return
		else
			board[i + the_pieces.piece2y][j + the_pieces.piece2x] = display.newRect((j + the_pieces.piece2x)* board_offset + x_offset, (i + the_pieces.piece2y)*board_offset + y_offset, block_size, block_size)
			board[i + the_pieces.piece2y][j + the_pieces.piece2x]:setFillColor(math.random(low_color, high_color) / 100 ,math.random(low_color, high_color) / 100, math.random(low_color, high_color) / 100)
			group:insert(board[i + the_pieces.piece2y][j + the_pieces.piece2x])
			--physics.addBody(board[i + the_pieces.piece2y][j + the_pieces.piece2x], "kinematic")
		end
		if i + the_pieces.piece3y > board_height or j + the_pieces.piece3x > board_width  or j + the_pieces.piece3x < 0 or i + the_pieces.piece3y < 0 then
			pause = true
			fail()
			return
		else
			board[i + the_pieces.piece3y][j + the_pieces.piece3x] = display.newRect((j + the_pieces.piece3x)*board_offset + x_offset, (i + the_pieces.piece3y)*board_offset + y_offset, block_size, block_size)
			board[i + the_pieces.piece3y][j + the_pieces.piece3x]:setFillColor(math.random(low_color, high_color) / 100 ,math.random(low_color, high_color) / 100, math.random(low_color, high_color) / 100)
			group:insert(board[i + the_pieces.piece3y][j + the_pieces.piece3x])
			--physics.addBody(board[i + the_pieces.piece3y][j + the_pieces.piece3x], "kinematic")
		end
		if i + the_pieces.piece4y > board_height or j + the_pieces.piece4x > board_width  or j + the_pieces.piece4x < 0 or i + the_pieces.piece4y < 0 then
			pause = true
			fail()
			return
		else
			board[i + the_pieces.piece4y][j + the_pieces.piece4x] = display.newRect((j + the_pieces.piece4x)* board_offset + x_offset, (i + the_pieces.piece4y)* board_offset + y_offset, block_size, block_size)
			board[i + the_pieces.piece4y][j + the_pieces.piece4x]:setFillColor(math.random(low_color, high_color) / 100 ,math.random(low_color, high_color) / 100, math.random(low_color, high_color) / 100)
			group:insert(board[i + the_pieces.piece4y][j + the_pieces.piece4x])
			--physics.addBody(board[i + the_pieces.piece4y][j + the_pieces.piece4x], "kinematic")
		end
		removeRows()
	end
end


--Redraws the entire board and randomizes the color.
function redraw()
	group:removeSelf()
	group = display.newGroup()
	for i = 0, board_height do
		for j = 0, board_width do
			if board[i][j] ~= 0 then
				board[i][j] = display.newRect((j * board_offset) + x_offset, (i * board_offset) + y_offset, block_size, block_size)
				board[i][j]:setFillColor(math.random(low_color, high_color) / 100 ,math.random(low_color, high_color) / 100, math.random(low_color, high_color) / 100)
				group:insert(board[i][j])
			end
		end
	end
end


--Used to move rows down after completion of of a line.
function rowFall(inital_row) 
	for i = inital_row, 0, -1 do
		for j = 0, board_width do
			if board[i][j] ~= 0 then
				board[i + 1][j] = board[i][j]
				board[i][j] = 0
			end
		end
	end
	redraw()
end


--Used to find and remove any completed rows.
function removeRows()
	rows = 0
	the_row = 0
	
	for i = 0, board_height do
		local boolean check = true
		for j = 0, board_width do
			if board[i][j] == 0 then
			check = false
			break
			end
		end
		if check then
			if the_row == 0 then
				the_row = i
			end
			rows = rows + 1
			for j = 0, board_width do
			 board[i][j]:removeSelf()
			 board[i][j] = 0
			end
			rowFall(the_row)
		end
	end
	updateScore(rows)
end


--Method to calculate if the top row has been filled. if so game over. 
function checkTopRow()
	local isPiece = false
	for j = 0, board_width do
		if board[0][j] ~= 0 then
		isPiece = true
		break
		end
	end
	return isPiece
end


--The logic to check if a move is possible given the numbers passed in, on the x and y axis.
function checkMove(dx, dy)
	if currentPiece == nil then
		return false
	end
	if currentPiece.x == nil then
		return false
	end
	local can = false
	local piece1 = false
	local piece2 = false
	local piece3 = false
	local piece4 = false
	local piece = pieceRotation(currentPiece)
	x = math.floor(currentPiece.x/board_offset)
	y = math.floor(currentPiece.y/board_offset)
	if piece.piece1x + x + dx >= 0 and piece.piece1x + x + dx <= board_width then
		if piece.piece2x + x + dx >= 0 and piece.piece2x + x + dx <= board_width then
			if piece.piece3x + x + dx >= 0 and piece.piece3x + x + dx <= board_width then
				if piece.piece4x + x + dx >= 0 and piece.piece4x + x + dx <= board_width then
					if  piece.piece1y + y + dy >=  0 and piece.piece2y + y + dy >=  0 and piece.piece3y + y + dy >=  0 and piece.piece4y + y + dy >=  0 then
						if  piece.piece1y + y + dy <= board_height then
							piece1 = true
							if  piece.piece2y + y + dy <= board_height then
								piece2 = true
								if  piece.piece3y + y + dy <= board_height then
									piece3 = true
									if piece.piece4y + y + dy <= board_height then
										piece4 = true
										--take current position add x and y and then check for a piece
										if board[y + piece.piece1y + dy][x + piece.piece1x + dx] == 0 then
											if board[y + piece.piece2y + dy][x + piece.piece2x + dx] == 0 then
												if board[y + piece.piece3y + dy][x + piece.piece3x + dx] == 0 then
													if board[y + piece.piece4y + dy][x + piece.piece4x + dx] == 0 then
														can = true
													end
												end
											end
										end
									end
								end
							end
						end
					else
						local test = checkTopRow()
						if test == false then
							can = true
						end
					
					end
				end
			end
		end
	end
	
	return can
end


--Calculates the x value to drop the piece in the current location.
function dropIndex()
	local index = 0
	for i = 1, 25 do
		local test = checkMove(0,i)
		if test then
			index = i
		else
			break
		end
	end
	return index
end


--Displays the ghost piece on the screen.
function ghostPiece()
	local index = dropIndex()
	local the_pieces = pieceRotation(currentPiece)
	
	local i = math.floor(currentPiece.y/height_offset)
	local j = math.floor(currentPiece.x/board_offset)
	
	ghost1 = display.newRect((j + the_pieces.piece1x) * board_offset + x_offset, (i + index + the_pieces.piece1y) * board_offset + y_offset, block_size, block_size)
	ghost2 = display.newRect((j + the_pieces.piece2x) * board_offset + x_offset, (i + index + the_pieces.piece2y) * board_offset + y_offset, block_size, block_size)
	ghost3 = display.newRect((j + the_pieces.piece3x) * board_offset + x_offset, (i + index + the_pieces.piece3y) * board_offset + y_offset, block_size, block_size)
	ghost4 = display.newRect((j + the_pieces.piece4x) * board_offset + x_offset, (i + index + the_pieces.piece4y) * board_offset + y_offset, block_size, block_size)
	
	ghost1:setFillColor(0, 0,1)
	ghost2:setFillColor(0, 0,1)
	ghost3:setFillColor(0, 0,1)
	ghost4:setFillColor(0, 0,1)
	
	ghost1.alpha = .4
	ghost2.alpha = .4
	ghost3.alpha = .4
	ghost4.alpha = .4
	
	
	if ghostGroup ~= nil then
		ghostGroup:removeSelf()
	end
	ghostGroup = display.newGroup()
	
	ghostGroup:insert(ghost1)
	ghostGroup:insert(ghost2)
	ghostGroup:insert(ghost3)
	ghostGroup:insert(ghost4)
	
end


--Listener method to drop the current piece.
function dropPiece()
	local index = dropIndex()
	currentPiece.y = currentPiece.y + (index * height_offset)
end


--Freezes the current piece updates the board and creates a new piece.
function freezePiece(freezeEvent)
	if pieceCreate == true then
		if soundEffects then
			audio.play(click)
		end
		local pieces = pieceRotation(currentPiece)
		--physics.removeBody(currentPiece)
		--physics.addBody(currentPiece, "static")
		currentPiece.myName = "death"
		pieceCreate = false
		randomizeColor()
		updateBoard(pieces)
		currentPiece:removeSelf()
		createPiece()
	end
end


--Forces the piece down after so many frames has passed.
function movePiece(moveEvent)
	update = update + 1
	if update % update_number == 0  and pause == false then
		if checkMove(0,1) then
			currentPiece.y = currentPiece.y + board_offset
		else
			freezePiece()
		end
		drawPiece(pieceRotation(currentPiece))
	end
end


--Rotates the current piece.
function rotate()
	if currentPiece == nil then
		return
	end
	if currentPiece.type == "oPiece" then
		return
	elseif currentPiece.type == "iPiece" or currentPiece.type == "zPiece" or  currentPiece.type == "sPiece" then
		if currentPiece.rotation == 90 then
			currentPiece.rotation = 0
			if checkMove(0,0) then
				--do nothing
			else 
				currentPiece.rotation = 0
			end
		else
			currentPiece.rotation = 90
			if checkMove(0,0) then
				--do nothing
			else 
				currentPiece.rotation = 0
			end
		end
		drawPiece(pieceRotation(currentPiece))
		return
	end
	currentPiece.rotation = currentPiece.rotation + 90
	if checkMove(0,0) then
		--do nothing
	else 
		currentPiece.rotation = currentPiece.rotation - 90
	end
	if currentPiece.rotation >= 360 then
		currentPiece.rotation = 0
	end
	drawPiece(pieceRotation(currentPiece))
end


--Listener method called when asked to move the piece left. if possible moves, if not nothing.
function moveLeft()
	if currentPiece == nil then
		return
	end
	if checkMove(-1, 0) then
		currentPiece.x = currentPiece.x - board_offset
	end
	drawPiece(pieceRotation(currentPiece))
end


--Listener method called when asked to move the piece right. if possible moves, if not nothing.
function moveRight()
	if currentPiece == nil then
		return
	end
	if checkMove(1,0) then
		currentPiece.x = currentPiece.x + board_offset
	end
	drawPiece(pieceRotation(currentPiece))
end


--Listener method for moving left using tap controls.
function tapMove(e) 
	if (pause) then 
		return
	elseif (e.x < 235/2) then
		moveLeft()
	elseif (e.x >= 235/2) and (e.x < 235) and checkMove(1, 0) then 
		moveRight()
	end
	drawPiece(pieceRotation(currentPiece))
	
end



--Listener method for droping the piece using tap controls
function dropPieceMotion(e)
	if (pause) then
		return
	elseif (e.yStart + 15 < e.y) and (e.phase == "ended") then
		dropPiece()
	end
end



--Prepopulates the boards with random blocks
function fillBoardCreate()
	local upperBound = fillBoard * 2
	for number = 0, upperBound do
		i = math.random(13, 23)
		j = math.random(0, 10)
		board[i][j] = display.newRect((j * board_offset) + x_offset, (i * board_offset) + y_offset, block_size, block_size)
		board[i][j]:setFillColor(math.random(low_color, high_color) / 100, math.random(low_color, high_color) / 100,math.random(low_color, high_color) / 100)
		group:insert(board[i][j])
	end
end
 

--Creates the game and all the stuff.
function create()
	start_over = true
	pause = false
	
	nextPieceGroup = display.newGroup()
	scoreGroup = display.newGroup()
	
	display1 = display.newRect(0,0,0,0)
	display2 = display.newRect(0,0,0,0)
	display3 = display.newRect(0,0,0,0)
	display4 = display.newRect(0,0,0,0)

	group = display.newGroup()
	extra_group = display.newGroup()
	createBoard()
	
	if fillBoard > 0 then
		fillBoardCreate()
	end
	
	if tapControl == false then
		local leftB = display.newImage("left_arrow.png")
		leftB.x = display.contentWidth - 40
		leftB.y = display.contentHeight / 6 + 10
		--leftB:scale(0.6, 0.6)
		leftB.width = 60
		leftB.height = 60
		leftB:addEventListener("tap", moveLeft)

		local rightB = display.newImage("right_arrow.png")
		rightB.x = display.contentWidth - 40
		rightB.y = display.contentHeight / 3 - 10
		--rightB:scale(0.6, 0.6)
		rightB.width = 60
		rightB.height = 60
		rightB:addEventListener("tap", moveRight)
	
		extra_group:insert(leftB)
		extra_group:insert(rightB)
		
		local dropB = display.newImage("down_arrow.png")
		dropB.x = display.contentWidth - 40
		dropB.y = display.contentHeight / 8 - 35
		dropB.width = 60
		dropB.height = 60
		dropB:addEventListener("tap", dropPiece)
		
	else
		Runtime:addEventListener("tap", tapMove)
		Runtime:addEventListener("touch", dropPieceMotion)
	end


	local rotateB = display.newImage("rotate2.png")
	rotateB.x = display.contentWidth - 40
	rotateB.y = display.contentHeight /3  + 60
	--rotateB:scale(0.5, 0.5)
	rotateB.width = 75
	rotateB.height = 65
	rotateB:addEventListener("tap", rotate) --switch to tap
	
	local pauseB = display.newImage("pause.png")
	pauseB.x = display.contentWidth - 50
	pauseB.y = (display.contentHeight / 5 )* 3
	pauseB.width = 50
	pauseB.height = 50
	
	pauseB:addEventListener("tap", pauseGame)
	
	extra_group:insert(rotateB)
	extra_group:insert(pauseB)

	createPiece()

	local floor = display.newImage("base.png")
	floor.x = display.contentWidth/2
	floor.y = display.contentHeight + 43
	floor.myName = "Floor"

	local leftWall = display.newRect(0,0,1, display.contentHeight*2 + 50)
	local rightWall = display.newRect(235, 0, 5, display.contentHeight*2 + 52)
	leftWall.myName = "leftWall"
	rightWall.myName = "rightWall"

	display.setStatusBar(display.HiddenStatusBar)
	
	extra_group:insert(floor)
	extra_group:insert(leftWall)
	extra_group:insert(rightWall)

	Runtime:addEventListener("enterFrame", movePiece)
	
	background = display.newImage("winter2.png", display.contentWidth/2, display.contentHeight/2)
	background.width = display.contentWidth
	background.height = display.contentHeight
	background:toBack();
	

	if music then
		audio.play(sfx.level_one, options)
	end
	Runtime:addEventListener("system", onSystemEvent)
	--timer.performWithDelay(1000,fail, 1)
end


--Attempt to pause game when lost focus. Does not work currently.
function onSystemEvent(event)
	if event.name == "applicationSuspend" then
		pauseGame()
	end
end


--A horrible hard coded method for each rotation for each piece using a local x and y 
--reference based off a central point. 
function pieceRotation(currentPiece)
--return xy, xy, xy, xy from current location of subpieces. 
--so a t piece in the down position at 105, 21 would return
--assuming xy location is down and right square
locations = {}
	

	if currentPiece.type == "tPiece" then --screwed
		if currentPiece.rotation == 0 then
			locations["piece1x"] = -1
			locations["piece1y"] = 0
			locations["piece2x"] = 0
			locations["piece2y"] = 0
			locations["piece3x"] = 0
			locations["piece3y"] = 1
			locations["piece4x"] = 1
			locations["piece4y"] = 0
		elseif currentPiece.rotation == 90 then 
			locations["piece1x"] = -1
			locations["piece1y"] = 0
			locations["piece2x"] = -1
			locations["piece2y"] = 1
			locations["piece3x"] = -2
			locations["piece3y"] = 0
			locations["piece4x"] = -1
			locations["piece4y"] = -1
		elseif currentPiece.rotation == 180 then
			locations["piece1x"] = -2
			locations["piece1y"] = -1
			locations["piece2x"] = -1
			locations["piece2y"] = -1
			locations["piece3x"] = -1
			locations["piece3y"] = -2
			locations["piece4x"] = 0
			locations["piece4y"] = -1
		else  --0,-1, 0,-2, 1,-1, 0,0
			locations["piece1x"] = 0
			locations["piece1y"] = -1
			locations["piece2x"] = 0
			locations["piece2y"] = -2
			locations["piece3x"] =  1
			locations["piece3y"] = -1
			locations["piece4x"] = 0
			locations["piece4y"] = 0
		end
	elseif currentPiece.type == "sPiece" then
		if currentPiece.rotation == 0 then 
			locations["piece1x"] = -1
			locations["piece1y"] = 0
			locations["piece2x"] = 0
			locations["piece2y"] = 0
			locations["piece3x"] = -1
			locations["piece3y"] = 1
			locations["piece4x"] = -2
			locations["piece4y"] = 1
		elseif currentPiece.rotation == 90 then
			locations["piece1x"] = -1
			locations["piece1y"] = -1
			locations["piece2x"] = -1
			locations["piece2y"] = 0
			locations["piece3x"] = 0
			locations["piece3y"] = 0
			locations["piece4x"] = 0
			locations["piece4y"] = 1
	end
	elseif currentPiece.type == "zPiece" then --screwed
		if currentPiece.rotation == 0 then -- 1,0, 0,0, 2,0, 1,1 -1x +1y
			locations["piece1x"] = 0
			locations["piece1y"] = 0
			locations["piece2x"] = -1
			locations["piece2y"] = 0
			locations["piece3x"] = 1
			locations["piece3y"] = 1
			locations["piece4x"] = 0
			locations["piece4y"] = 1
		elseif currentPiece.rotation == 90 then -- -1,0, -2,0, -2,1, -1,-1
			locations["piece1x"] = -1
			locations["piece1y"] = 0
			locations["piece2x"] = -2
			locations["piece2y"] = 0
			locations["piece3x"] = -2
			locations["piece3y"] = 1
			locations["piece4x"] = -1
			locations["piece4y"] = -1
		end
	elseif currentPiece.type == "oPiece" then
		locations["piece1x"] = 0
		locations["piece1y"] = 0
		locations["piece2x"] = 0
		locations["piece2y"] = 1
		locations["piece3x"] = 1
		locations["piece3y"] = 0
		locations["piece4x"] = 1
		locations["piece4y"] = 1
	elseif currentPiece.type == "iPiece" then
		if currentPiece.rotation == 0 then -- 0,0, 0,1, 0,-1, 0,-21
			locations["piece1x"] = 0
			locations["piece1y"] = 0
			locations["piece2x"] = 0
			locations["piece2y"] = 1
			locations["piece3x"] = 0
			locations["piece3y"] = -1
			locations["piece4x"] = 0
			locations["piece4y"] = -2
		elseif currentPiece.rotation == 90 then -- 0,0 1,0, -1,0, -2,0
			locations["piece1x"] = 0
			locations["piece1y"] = 0
			locations["piece2x"] = 1
			locations["piece2y"] = 0
			locations["piece3x"] = -1
			locations["piece3y"] = 0
			locations["piece4x"] = -2
			locations["piece4y"] = 0
		end
	elseif currentPiece.type == "lPiece" then
		if currentPiece.rotation == 0 then -- 0,0, 0,-1, 0,1, 1,1
			locations["piece1x"] = 0
			locations["piece1y"] = 0
			locations["piece2x"] = 0
			locations["piece2y"] = -1
			locations["piece3x"] = 0
			locations["piece3y"] = 1
			locations["piece4x"] = 1
			locations["piece4y"] = 1
		elseif currentPiece.rotation == 90 then -- 0,0, -1,0, -2,0, -2,1
			locations["piece1x"] = 0
			locations["piece1y"] = 0
			locations["piece2x"] = -1
			locations["piece2y"] = 0
			locations["piece3x"] = -2
			locations["piece3y"] = 0
			locations["piece4x"] = -2
			locations["piece4y"] = 1
		elseif currentPiece.rotation == 180 then -- -1,0, -1,-1, -1,-2, -2,-2
			locations["piece1x"] = -1
			locations["piece1y"] = 0
			locations["piece2x"] = -1
			locations["piece2y"] = -1
			locations["piece3x"] = -1
			locations["piece3y"] = -2
			locations["piece4x"] = -2
			locations["piece4y"] = -2
		else  -- -1,-1, 0,-1, 1,-1, 1,-2
			locations["piece1x"] = -1
			locations["piece1y"] = -1
			locations["piece2x"] = 0
			locations["piece2y"] = -1
			locations["piece3x"] =  1
			locations["piece3y"] = -1
			locations["piece4x"] = 1
			locations["piece4y"] = -2
		end
	else
		if currentPiece.rotation == 0 then -- 0,0, 0,1, -1,1, 0,-10
			locations["piece1x"] = 0
			locations["piece1y"] = 0
			locations["piece2x"] = 0
			locations["piece2y"] = 1
			locations["piece3x"] = -1
			locations["piece3y"] = 1
			locations["piece4x"] = 0
			locations["piece4y"] = -1
		elseif currentPiece.rotation == 90 then -- -2,-1, -2,0, -1,0, 0,0
			locations["piece1x"] = -2
			locations["piece1y"] = -1
			locations["piece2x"] = -2
			locations["piece2y"] = 0
			locations["piece3x"] = -1
			locations["piece3y"] = 0
			locations["piece4x"] = 0
			locations["piece4y"] = 0
		elseif currentPiece.rotation == 180 then -- -1,0, -1,-1, -1,-2, 0,-2
			locations["piece1x"] = -1
			locations["piece1y"] = 0
			locations["piece2x"] = -1
			locations["piece2y"] = -1
			locations["piece3x"] = -1
			locations["piece3y"] = -2
			locations["piece4x"] = 0
			locations["piece4y"] = -2
		else  -- 0,-1, -1,-1, 1,-1, 1,0
			locations["piece1x"] = 0
			locations["piece1y"] = -1
			locations["piece2x"] = -1
			locations["piece2y"] = -1
			locations["piece3x"] =  1
			locations["piece3y"] = -1
			locations["piece4x"] = 1
			locations["piece4y"] = 0
		end
	end
	return locations
end


--Starts the game by starting the menu screen. game is reactionary after this point. 
addMenuScreen()

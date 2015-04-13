root = exports ? this

window.onload = ->

	root.ach9 = 0
	root.gameConfig = {
		lvl: [
			[1,0]
			[2,20]
			[3,45]
			[4,75]
			[5,110]
			[6,150]
			[7,195]
			[8,245]
			[9,300]
			[10,360]
		]
		score: [null,null]
		achieve: 
			descript: [
				'Receive "A" rank'
				'Receive "S" rank'
				'Receive "SS" rank'
				'Receive "SSS" rank'
				'Clear 4 lines in single drop [ Tetris ]'
				'Clear same color of line [ Tetris ]'
				'Left 3 lifes even game end [ Pong ]'
				'Play game at least 1 time'
				'Play tetris game in 1 second'
				'Die both game in same time'
				'Reach to maximum level of both game ( Level 10 )'
				'Play game at least 5 minutes'
				'Every subscore (except \'other\') in both game not different more than 5%'
				'Receive score without move [ Pong ]'
				'Visit credit page :D'
				'Receive "SSS" rank in "every subscore" in "both game" ( Oh GOD )'
			]
			score: (0 for [0...16])
	}
	
	class tetris
		_gameState = null
		_timeRender = null
		_timeScore = null
		stage = ('E' for [0...10] for [0...20])
		canvas = null
		layer = []
		score =
			game: 'tetris'
			score: 0
			level: 0
			line: 0
			time: 0
		log =
			nextShape: 'E'
			curShape: 'E'
			movingPiece: []
			state: 'begin'
			speed: 1000
			randPiece: []
		colorMap =
			I:'#00BFFF'
			J:'#104E8B'
			L:'#FF7F24'
			O:'#FFB90F'
			S:'#9ACD32'
			T:'#473C8B'
			Z:'#CD0000'
		shapeMap =
			I: [
				[1,1,1,1]
			]
			J: [
				[1,0,0]
				[1,1,1]
			]
			L: [
				[0,0,1]
				[1,1,1]
			]
			O:[
				[1,1]
				[1,1]
			]
			S:[
				[0,1,1]
				[1,1,0]
			]
			T:[
				[0,1,0]
				[1,1,1]
			]
			Z:[
				[1,1,0]
				[0,1,1]
			]
		
		setSpeed = ( level )->
			log.speed = (11-level)*100
			score.level = level
		
		moveShape: (type)->
			
			if log.state isnt "play" then return
			
			tmp = ([c[0],c[1]] for c in log.movingPiece)
			pass = true
			
			for c in tmp
				if type is 'L' then --c[0] else if type is 'R' then ++c[0] else ++c[1]
				if !( 0 <= c[0] < 10 ) or c[1] >= 20 or ( c[1] >= 0 and stage[c[1]][c[0]] != 'E' )
					pass = false
					break
			if pass
				log.movingPiece = tmp
				prevShape()
				
		rotation: ->
			
			if log.state isnt "play" then return
			
			cx = ( (Math.max (c[0] for c in log.movingPiece)...) + (Math.min (c[0] for c in log.movingPiece)...) )/2
			pcx = ( cx - Math.floor(cx) ) isnt 0
			cx = Math.floor(cx)
			cy = Math.ceil( ( (Math.max (c[1] for c in log.movingPiece)...) + (Math.min (c[1] for c in log.movingPiece)...) )/2 )
			
			
			tmp = ( [ -(c[1]-cy)+cx, c[0]-cx+cy ] for c in log.movingPiece )
			
			sx = Math.min ( c[0] for c in tmp )...
			sx = Math.min 0,sx
			ex = Math.max ( c[0] for c in tmp )...
			ex = Math.max 9,ex
			ey = Math.max ( c[1] for c in tmp )...
			ey = Math.max 19,ey
			
			tmp = 
				for c in tmp
					x = ( if ex >= 10 then c[0]-(ex-9) else if sx < 0 then c[0]-sx else c[0] )
					y = c[1]-pcx-( if ey > 19 then ey-19 else 0 )
					[x,y]
			
			pass = true		
			for c in tmp
				if c[1] >= 0 and stage[c[1]][c[0]] isnt 'E'
					pass = false
					break
				
			if pass
				log.movingPiece = tmp
				prevShape()
			
		drawStage = ->
			layer[3].removeChildren()
			layer[3].remove()
			for i in [0...20]
				for j in [0...10]
					if stage[i][j] is 'E'
						continue
					elm = new Kinetic.Rect
						x: 170 + j*25
						y: 20 + i*25
						width: 24
						height: 24
						fill: colorMap[stage[i][j]]
					layer[3].add elm
			
			canvas.add layer[3]
			return
		
		updateScore = ( phase=0 )->
			
			layer[4].removeChildren()
			layer[4].remove()
			
			c = 0
			
			tmp = score.time
			
			score.time = ( score.time/10 || 0 ) + " s"
			
			newlvl = 0
			for i in root.gameConfig.lvl
				if tmp/10 > i[1]
					newlvl = i[0]
			setSpeed newlvl
			
			for i,v of score
				if i is 'game'
					continue
				elm = new Kinetic.Text
					x: 30
					y: 440+c*17
					text: (i.substr(0,1).toUpperCase() + i.substr(1) + ' : '+v)
					fontSize: 14
					fontFamily: "arial"
					fill: '#FFF'
				layer[4].add elm
				c++
			
			if phase isnt 0
				elm = new Kinetic.Rect
					x: 170
					y: 20
					width: 250
					height: 500
					opacity: 0.5
					fill: '#000'
				layer[4].add elm
				
				textShow = [0,"Click Play to Start Game","Game Over","Pause","Bad Luck"]
				
				elm = new Kinetic.Text
					x: 170+250/2-100
					y: 20+500/2
					text: textShow[phase]
					fontSize: 70
					fontFamily: "bebas"
					fill: '#FF8C00'
					width: 200
					align: 'center'
				if phase is 1
					elm.setY( 170+500/2-320 )
				else if phase is 2
					elm.setY( 170+500/2-220 )
				else if phase is 3
					elm.setY( 170+500/2-180 )
				else if phase is 4
					elm.setY( 170+500/2-220 )
				layer[4].add elm
				
			if phase is 0
				score.time = parseInt(tmp) + 1
			else
				score.time = tmp
			
			canvas.add layer[4]
			return
		
		placeShape = ->
		
			(if c[1] >= 0 then stage[c[1]][c[0]] = log.curShape) for c in log.movingPiece
			
			drawStage()
			
			rev = []
			countline = 0
			colorline = 0
			for i in [19..0]
				pass = true
				for j in [0...10]
					if stage[i][j] is 'E'
						pass = false
				if !pass
					rev.push i
				else
					colorline = 1
					for j in [1...10]
						if stage[i][j] isnt stage[i][0] then colorline = 0
					if colorline
						root.gameAchievement 2,5
					countline++
			
			if countline is 4
				root.gameAchievement 2,4
	
			score.score = parseInt(score.score) +  (20-rev.length) * (20-rev.length) * 100 * (11-(log.speed/100))
			score.line = parseInt(score.line) + (20-rev.length)
					
			if rev.length isnt 0
				for i in [19...0]
					if rev.length is 0
						for j in [0...10] then stage[i][j] = 'E'
					else
						for j in [0...10] then stage[i][j] = stage[rev[0]][j]
						rev.shift()
				
				drawStage()
				genNextShape()
				return
			else 
				genNextShape()
			
			return
		shapeDownDrop: ->
		
			if log.state isnt 'play' then return
		
			btm = log.movingPiece
			while true
				pass = true
				for i,c of btm
					if ++btm[i][1] < 0 then continue
					if c[1] >= 20 or stage[c[1]][c[0]] != 'E'
						pass = false
				if !pass
					--btm[i][1] for i,c of btm
					break
			log.movingPiece = btm
			shapeDown()
			
		shapeDown = ->
			
			mvp = log.movingPiece
			
			mvp = ( [crd[0],crd[1]+1] for crd in mvp )
			
			if (Math.max (c[1] for c in mvp)...) >= 20 or !( ( (if c[1] >= 0 then stage[c[1]][c[0]] else 'E') for c in mvp).every (x)-> x == 'E' )
				if (Math.min (c[1] for c in mvp)...) < 0
					gameEnd()
					return
				score.score = parseInt(score.score) + (11-(log.speed/100)) + 10
				placeShape()
				return 
			
			
			log.movingPiece = mvp
			prevShape()
			
			clearTimeout _timeRender
			_timeRender = setTimeout shapeDown,log.speed
			
			return
		genNextShape = ->
			tmp = log.nextShape
			
			if log.randPiece.length is 0
				sq = ["I","J","L","O","S","T","Z"];
				
				for [1..10]
					a = Math.floor(Math.random()*sq.length)
					b = Math.floor(Math.random()*sq.length)
					t = sq[a]
					sq[a] = sq[b]
					sq[b] = t
				
				sq = sq.slice(0,6+Math.floor(Math.random()*2))
				
				log.randPiece = sq
			
			newS = log.nextShape = log.randPiece.shift()
			
			if tmp is 'E'
				genNextShape()
				return
			
			sx = 20+130/2 - shapeMap[newS][0].length*28/2;
			sy = 20+90/2 - shapeMap[newS].length*30/2;
			
			layer[1].removeChildren()
			layer[1].remove()
			
			for i,v of shapeMap[newS]
				for j,vj of v
					if vj is 0
						continue
					elm = new Kinetic.Rect
						x: sx + j*28
						y: sy + i*28 + 30
						width: 26
						height: 26
						fill: colorMap[newS]
					layer[1].add elm
			
			elm = new Kinetic.Rect
				x: 20
				y: 20+30
				width: 130
				height: 90
				opacity: 0.03
				fill: colorMap[newS]
			layer[1].add elm
			
			elm = new Kinetic.Rect
				x: 18
				y: 18+30
				width: 134
				height: 94
				opacity: 0.2
				stroke: colorMap[newS]
				strokeWidth: 0
			layer[1].add elm
			
			canvas.add layer[1]
			
			h = shapeMap[tmp].length
			log.movingPiece = []
			( ( if vj is 1 then log.movingPiece.push [5-Math.floor(v.length/2)+parseInt(j),i-h]) for j,vj of v for i,v of shapeMap[tmp])
			
			log.curShape = tmp
			shapeDown()
			
			return
			
		constructor: ( state )->
			_gameState = state
			init()
		
		gameBegin: ->
			log.state = 'play'
			score.level = 1
			updateScore()
			genNextShape()
			_timeScore = setInterval updateScore,100
			return
		gamePause: ->
			if log.state is 'end' then return
			log.state = 'pause'
			updateScore(3)
			clearTimeout _timeRender
			clearInterval _timeScore
			return
		gameResume: ->
			if log.state is 'end' then return
			log.state = 'play'
			_timeScore = setInterval updateScore,100
			shapeDown()
			return
		gameEnd = ->
			log.state = 'end'
			updateScore(2)
			clearTimeout _timeRender
			clearInterval _timeScore
			root.gameEnd( _gameState )
			return
		gameEndBefore: ->
			if log.state isnt 'end'
				log.state = 'end'
				updateScore(4)
				clearTimeout _timeRender
				clearInterval _timeScore
		gameReset: ->
			clearInterval _timeRender
			clearInterval _timeScore
			stage = ('E' for [0...10] for [0...20])
			score =
				game: 'tetris'
				score: 0
				level: 0
				line: 0
				time: 0
			log =
				nextShape: 'E'
				curShape: 'E'
				movingPiece: []
				state: 'begin'
				speed: 1000
				randPiece: []
			drawStage()
			
		init = ->
			canvas = new Kinetic.Stage
				container: 'tetris'
				width: 438
				height: 540
			
			layer = []
			
			for i in [0...5]
				layer[i] = new Kinetic.Layer()
			
			#stage
			
			elm = new Kinetic.Rect
				x: 150+20
				y: 20
				width: 250
				height: 500
				fill: '#DDD'
			layer[0].add elm
			
			elm = new Kinetic.Rect
				x: 150+18
				y: 18
				width: 254
				height: 504
				stroke: '#EEE'
				strokeWidth: 0
			layer[0].add elm
			
			#Next thum
			
			elm = new Kinetic.Rect
				x: 20
				y: 20+30
				width: 130
				height: 90
				fill: '#DDD'
			layer[0].add elm
			
			elm = new Kinetic.Rect
				x: 18
				y: 18+30
				width: 134
				height: 94
				stroke: '#EEE'
				strokeWidth: 0
			layer[0].add elm
			
			#Next head
			
			elm = new Kinetic.Shape
				drawFunc : (canvas)->
					c = canvas.getContext()
					c.beginPath()
					c.moveTo 18,47
					c.lineTo 18,18
					c.lineTo 100,18
					c.lineTo 130,47
					c.closePath()
					canvas.fillStroke this
				fill: '#300'
			layer[0].add elm
			
			elm = new Kinetic.Text
				x: 30
				y: 24
				text: 'Next'
				fontSize: 18
				fontFamily: "bebas"
				fill: '#FFF'
			layer[0].add elm
			
			#Score
			
			elm = new Kinetic.Rect
				x: 18
				y: 404
				width: 134
				height: 120
				fill: '#698B22'
			layer[0].add elm
			
			elm = new Kinetic.Text
				x: 27
				y: 414
				text: 'Score'
				fontSize: 18
				fontFamily: "bebas"
				fill: '#FFF'
			layer[0].add elm
			
			#tutorial
			
			
			img = new Image()
			img.onload = ->
				elm = new Kinetic.Image
					x: 18
					y: 160
					width: 134
					height: 120
					image: img
				layer[0].add elm
				canvas.add layer[0]
				
				updateScore(1)
				
				return
			img.src = "t1.png"
			
			return
		prevShape = ->
		
			mvp = log.movingPiece
			btm = ( [c[0],c[1]] for c in log.movingPiece)
			
			while true
				pass = true
				for i,c of btm
					if ++btm[i][1] < 0 then continue
					if c[1] >= 20 or stage[c[1]][c[0]] != 'E'
						pass = false
				if !pass
					--btm[i][1] for i,c of btm
					break
			
			layer[2].removeChildren()
			layer[2].remove()
			
			for coord in mvp
				if coord[1] < 0
					continue
				elm = new Kinetic.Rect
					x: 170 + coord[0]*25
					y: 20 + coord[1]*25
					width: 24
					height: 24
					fill: colorMap[log.curShape]
				layer[2].add elm
			
			for coord in btm
				if coord[1] < 0
					continue
				elm = new Kinetic.Rect
					x: 170 + coord[0]*25
					y: 20 + coord[1]*25
					width: 24
					height: 24
					opacity: 0.2
					fill: colorMap[log.curShape]
				layer[2].add elm
			
			canvas.add layer[2]
			
		getScore: ->
			return score
		
		test: 
			test2: ->
				log.state = 'end'
				clearTimeout _timeRender
				for i in[19..4]
					for j in[0...10]
						stage[i][j] = "IIIIE"[Math.floor(Math.random()*5)]
				drawStage()
				$(document).keydown (e)->
					rev = []
					for i in [19..0]
						pass = true
						for j in [0...10]
							if stage[i][j] is 'E'
								pass = false
						if !pass
							rev.push i
						else
							for j in [0...10] 
								stage[i][j] = 'O'
					
					drawStage()
					
					
					$(document).keydown (e)->
						for i in [19...0]
							if rev.length is 0
								for j in [0...10] then stage[i][j] = 'E'
							else
								for j in [0...10] then stage[i][j] = stage[rev[0]][j]
								rev.shift()
						drawStage()
			stop: ->
				log.state = 'end'
				clearTimeout _timeRender
	

	###
	---------------------------------------------------------
	Game Pong
	---------------------------------------------------------
	###
	
	class pong
		_gameState = null
		canvas = null
		layer = null
		_interval =
			score: null
		map = null
		score =
			game: 'pong'
			score: 0
			level : 0
			lifes: 3
			time: 0
			move: 0
		interact = 
			board: null
			enimies: null
			ballDir: []
			speed: 1000
		log = 
			state: 'begin'
		
		setSpeed = ( level )->
			interact.speed = (11-level)*100
			score.level = level
		
		gameBegin: ->
			log.state = 'play'
			score.level = 1
			_interval.score = setInterval updateScore,100
			updateScore()
			initStage()
		gamePause: ->
			if log.state is 'die' then return
			log.state = 'pause'
			clearInterval _interval.score
			updateScore 3
		gameResume: ->
			if log.state is 'die' then return
			if log.state is 'pausedie'
				initStage()
			log.state = 'play'
			clearInterval _interval.score
			_interval.score = setInterval updateScore,100
		gameDie = ->
			score.move = 0
			if --score.lifes <= 0 
				gameEnd()
				return
			updateScore()
			clearInterval _interval.score
			setTimeout ->
				if log.state is 'pause'
					log.state = 'pausedie'
					return
				_interval.score = setInterval updateScore,100
				initStage()
			,1000
		gameEnd = ->
			log.state = 'die'
			clearInterval _interval.score
			updateScore 2
			root.gameEnd( _gameState )
		gameEndBefore: ->
			if log.state isnt 'die'
				log.state = 'die'
				clearInterval _interval.score
				updateScore 4
		gameReset: ->
			clearInterval _interval.score
			score =
				game: 'pong'
				score: 0
				level : 0
				lifes: 3
				time: 0
				move: 0
			log.state = 'begin'
			interact = 
				board: null
				enimies: null
				ballDir: []
				speed: 1000
			map = null
			
			
		constructor: (state)->
			_gameState = state
			init()
		init = ->
			canvas = new Kinetic.Stage
				container: 'pong'
				width: 442
				height: 540
			
			layer = []
			
			for i in [0...4]
				layer[i] = new Kinetic.Layer()
			
			#stage
			
			elm = new Kinetic.Rect
				x: 20
				y: 20
				width: 250
				height: 500
				fill: '#DDD'
			layer[0].add elm
			
			elm = new Kinetic.Rect
				x: 18
				y: 18
				width: 254
				height: 504
				stroke: '#EEE'
				strokeWidth: 0
			layer[0].add elm
			
			#Score
			
			elm = new Kinetic.Rect
				x: 270+18
				y: 404
				width: 134
				height: 120
				fill: '#698B22'
			layer[0].add elm
			
			elm = new Kinetic.Text
				x: 270+27
				y: 414
				text: 'Score'
				fontSize: 18
				fontFamily: "bebas"
				fill: '#FFF'
			layer[0].add elm
			
			#tutorial
			
			
			img = new Image()
			img.onload = ->
				elm = new Kinetic.Image
					x: 270+18
					y: 160
					width: 134
					height: 120
					image: img
				layer[0].add elm
				canvas.add layer[0]
				
				updateScore(1)
				
				return
			img.src = "t2.png"
			
			return
		
		initStage = ->
			interact.board = 3
			interact.enimies = 3
			interact.ballDir = [[1,-1],[-1,-1]][Math.floor(Math.random()*2)]
			
			prevRender()
			ballRender()
			
		move: (type)->
			
			if log.state isnt 'play' then return
			
			tmp = interact.board
			
			if type is 'L'
				if tmp isnt 0
					tmp--
			else
				if tmp+3 isnt 9
					tmp++
			
			interact.board = tmp
			prevRender()
			
			score.move++
			
			return
		
		ballRender = ()->
			
			layer[2].removeChildren()
			layer[2].remove()
			
			intt = interact
			count = 1
			bs = 6
			
			x = 20 + [4,5][Math.floor(Math.random()*2)]*25 + 12.5
			y = 20 + 18*25 - bs
			
			elm = new Kinetic.Circle
				x: x
				y: y
				radius : bs
				fill: '#CD0000'
			layer[2].add elm
			
			stop = false
			
			if intt.speed isnt 0
				aim = new Kinetic.Animation (frame)->
					
					if stop
						aim.stop()
						gameDie()
					
					intt = interact
					speed = intt.speed
					
					if log.state isnt 'play' 
						if log.state is 'die' then aim.stop()
						else return ;
					
					check = intt.board <= Math.floor((x-20)/25) <= intt.board+3
					
					#time = frame.time - speed*(count-1)
					if x >= 20 + 10*25 - bs
						intt.ballDir[0] *= -1
						x = 20 + 10*25 - bs
					if x <= 20 + bs
						intt.ballDir[0] *= -1
						x = 20 + bs
					if y <= 20 + 2*25 + bs
						intt.ballDir[1] *= -1
						y = 20 + 2*25 + bs
					if ( 20 + 18*25 - bs <= y <= 20 + 18*25 + 12.5 ) and check
						if count isnt 1
							score.score += (11-(speed/100))*( if intt.board < Math.floor((x-20)/25) < intt.board+3 then 10 else 20 ) + 100
							score.score += Math.max 0,10-score.move
							if score.move is 0 then root.gameConfig.achieve.score[13] = 1
						intt.ballDir[1] *= -1
						score.move = 0
						y = 20 + 18*25 - bs
						
					x += 100*(frame.timeDiff/speed)*intt.ballDir[0]
					y += 100*(frame.timeDiff/speed)*intt.ballDir[1]
					
					if y >= 20 + 20*25 - bs
						y = 20 + 20*25 - bs
						stop = true
					
					elm.setX x
					elm.setY y
					
					if frame.time >= speed/4*count
					
						sx = Math.floor (x-20)/25
						if sx < intt.enimies
							interact.enimies--
						else if sx > intt.enimies+4-1
							interact.enimies++
						else
							rand = [1*intt.ballDir[0],0,0,0,0][Math.floor(Math.random()*6)]
							tmp = intt.enimies+rand
							pass = false
							if tmp <= sx < tmp+4 then pass = true
							if !( 0 <= tmp <= 6 ) then pass = false
							if pass
								intt.enimies = tmp
								
						prevRender()
						count++
				, layer[2]
				
				aim.start()
				
			canvas.add layer[2]
		
		prevRender = ->
			
			layer[1].removeChildren()
			layer[1].remove()
			
			for c in [interact.board...(interact.board+4)]
				elm = new Kinetic.Rect
					x: 20 + c*25
					y: 20 + 18*25
					width: 24
					height: 12
					fill: '#ff8b00'
				layer[1].add elm
			
			for c in [interact.enimies...(interact.enimies+4)]
				elm = new Kinetic.Rect
					x: 20 + c*25
					y: 20 + 1*25 + 12.5
					width: 24
					height: 12
					fill: '#320000'
				layer[1].add elm
			
			canvas.add layer[1]
		
		updateScore = ( phase=0 )->
			
			layer[3].removeChildren()
			layer[3].remove()
			
			c = 0
			
			tmp = score.time
			
			score.time = ( score.time/10 || 0 ) + " s"
			
			newlvl = 0
			for i in root.gameConfig.lvl
				if tmp/10 > i[1]
					newlvl = i[0]
			setSpeed newlvl
			
			for i,v of score
				if i is 'move' or i is 'game'
					continue
				elm = new Kinetic.Text
					x: 300
					y: 440+c*17
					text: (i.substr(0,1).toUpperCase() + i.substr(1) + ' : '+v)
					fontSize: 14
					fontFamily: "arial"
					fill: '#FFF'
				layer[3].add elm
				c++
			
			if phase isnt 0
				elm = new Kinetic.Rect
					x: 20
					y: 20
					width: 250
					height: 500
					opacity: 0.5
					fill: '#000'
				layer[3].add elm
				
				textShow = [0,"Click Play to Start Game","Game Over","Pause","Bad Luck"]
				
				elm = new Kinetic.Text
					x: 20+250/2-100
					y: 20+500/2
					text: textShow[phase]
					fontSize: 70
					fontFamily: "bebas"
					fill: '#FF8C00'
					width: 200
					align: 'center'
				if phase is 1
					elm.setY( 170+500/2-320 )
				else if phase is 2
					elm.setY( 170+500/2-220 )
				else if phase is 3
					elm.setY( 170+500/2-180 )
				else if phase is 4
					elm.setY( 170+500/2-220 )
				layer[3].add elm
				
			if phase is 0
				score.time = parseInt(tmp) + 1
			else
				score.time = tmp
			
			canvas.add layer[3]
			return
			
		getScore: ->
			return score
		
	$(document).keydown (e)->
		#37 left 39 right
		
		key = [32,37,38,39,40]
		if key.indexOf(e.which) isnt -1
			e.preventDefault()
		switch e.which
			when 32 then root.game.shapeDownDrop()
			when 37
				root.game.moveShape 'L'
				root.game2.move 'L'
			when 38 then root.game.rotation()
			when 39
				root.game.moveShape 'R'
				root.game2.move 'R'
			when 40 then root.game.moveShape 'D'
			
	root.game = new tetris(1)
	root.game2 = new pong(2)
	
	root.gameStart = ()->
		ach9 = 0
		root.game.gameReset()
		root.game2.gameReset()
		root.game.gameBegin()
		root.game2.gameBegin()

	root.gameEnd = (which)->
		ach9++
		if which is 1
			setTimeout ->
				root.game2.gameEndBefore()
				root.gameShowRank()
				root.gameAchievement()
			,1000
		else
			setTimeout ->
				root.game.gameEndBefore()
				root.gameShowRank()
				root.gameAchievement()
			,1000
	
	root.gameShowRank = ()->
		
		if root.gameConfig.score[0] isnt null then return
		root.gameConfig.score[0] = root.game.getScore()
		root.gameConfig.score[1] = root.game2.getScore()
		
		$("#handle").text('Play')
		
		a = [ root.gameConfig.score[0],root.gameConfig.score[1] ]
		
		grading = ( v )->
			s = [200,160,120,90,60,40,20,10,0]
			g = ['SSS','SS','S','A','B','C','D','E','F']
			
			if g.indexOf(v) isnt -1
				return s[g.indexOf(v)]/100
			
			v = v*100+1
			for i in [0...s.length]
				if v > s[i] then return g[i]
		
		
		lastgrade = 0
		ach12 = true
		ach15 = true
		
		for i,v of a[0]
		
			if i is 'lifes'
				i = 'line'
				
			n = ['game','score','level','line','time'].indexOf(i)
			if n is -1 then continue
			
			j = i
			if i is 'line' and a[0]['game'] is 'pong' then i = 'lifes'
			if j is 'line' and a[1]['game'] is 'pong' then j = 'lifes'
			
			ii = a[0][i]
			jj = a[1][j]
			if i isnt 'game'
				ii = parseInt(ii)
				jj = parseInt(jj)
			
			s = ["","",""]
			kk = 0
			
			#scoring
			switch i
				when 'score'
					max = if a[0]['game'] is 'tetris' then 35000 else 15000
					s[0] = grading( ii/max )
					max = if a[1]['game'] is 'tetris' then 35000 else 15000
					s[1] = grading( jj/max )
					if Math.abs( ii-jj )/Math.max( ii,jj ) > 0.05 then ach12 = false
					kk = ii + jj
					s[2] = grading( kk/50000 )
					lastgrade += ( grading(s[0])+grading(s[1]) )/2*2
				when 'level'
					s[0] = grading( ii*ii/50 )
					s[1] = grading( jj*jj/50 )
					if Math.abs( ii-jj )/Math.max( ii,jj ) > 0.05 then ach12 = false
					if Math.min( ii,jj ) is 10 then root.gameConfig.achieve.score[10] = 1
					kk = Math.max( ii,jj )
					s[2] = grading( kk*kk/50 )
					lastgrade += ( grading(s[0])+grading(s[1]) )/2*2
				when 'line','lifes'
					if i is 'line' then s[0] = grading( ii/50 )
					if j is 'line' then s[1] = grading( jj/50 )
					if i is 'lifes' then s[0] = grading( (ii*(11/3)+9)/10 )
					if j is 'lifes' then s[1] = grading( (jj*(11/3)+9)/10 )
					lastgrade += Math.min( grading(s[0]),grading(s[1]) )
				when 'time'
					s[0] = grading( ii/3600 )
					s[1] = grading( jj/3600 )
					s[2] = grading( Math.max(ii,jj)/3600 )
					kk = Math.max( ii,jj )/10 + ' S'
					
					if Math.min( ii,jj ) > 3000 then root.gameConfig.achieve.score[11] = 1
					if Math.abs( ii-jj )/Math.max( ii,jj ) > 0.05 then ach12 = false
					if i is 'time' and ii < 10
						root.gameAchievement 2,8
					
					ii = ii/10 + ' S'
					jj = jj/10 + ' S'
					lastgrade += ( grading(s[0])+grading(s[1]) )/2*2
				
			if j is 'lifes' and jj is 3
				root.gameAchievement 2,6
			if s[0] isnt 'SSS' or s[1] isnt 'SSS'
				ach15 = false
				
			if i isnt 'game'
				if i is 'line' or i is 'lifes'
					if i is 'line' then i += 's'
					if j is 'line' then j += 's'
					ii = "#{ii}&nbsp;&nbsp;#{i}&nbsp;&nbsp;<span style='color:#300;'>[ #{s[0]} ]</span>"
					jj = "#{jj}&nbsp;&nbsp;#{j}&nbsp;&nbsp;<span style='color:#300;'>[ #{s[1]} ]</span>"
					if grading(s[0]) < grading(s[1]) then kk = ii else kk = jj
				else
					ii = "#{ii}&nbsp;&nbsp;&nbsp;&nbsp;<span style='color:#300;'>[ #{s[0]} ]</span>"
					jj = "#{jj}&nbsp;&nbsp;&nbsp;&nbsp;<span style='color:#300;'>[ #{s[1]} ]</span>"
					kk = "#{kk}&nbsp;&nbsp;&nbsp;&nbsp;<span style='color:#300;'>[ #{s[2]} ]</span>"
				
			
			$("#score-ct .summary table tr:eq("+n+") td:eq(1)").html( "#{ii}" )
			$("#score-ct .summary table tr:eq("+n+") td:eq(2)").html( "#{jj}" )
			if i isnt 'game'
				$("#score-ct .summary table tr:eq("+n+") td:eq(3)").html( "#{kk}" )
		
		
		if ach12 is true
			root.gameAchievement 2,12
		if ach15 is true
			root.gameAchievement 2,15
		
		lastgrade = grading( lastgrade/7 )
		quote = [
			["You're not human !!!!","OMG, WTF, How can you do that !!?","%)@^#!$%|<*#)+_#!~","You are GODDD !!!!"]
			["Impossible !!!","How many brains you have ?","You completely talented !!!"]
			["Perfect !!","OMGGG !!","Very impressive"]
			["Excellent !","Very Very Good","WOW !","Genius"]
			["Cool","Great","Good"]
			["Ordinary","Normal","Regular"]
			["Not bad","Ok"]
			["Try again later","Not good enough","Try one more time"]
			["What are you doing ?","Don't hold spacbar","......"]
		][ ['SSS','SS','S','A','B','C','D','E','F'].indexOf(lastgrade) ]
		quote = quote[Math.floor(Math.random()*quote.length)]
		
		$("#score-ct .summary table tr:last-child td:last-child")
			.html( lastgrade+"&nbsp;&nbsp;&nbsp;&nbsp;<span style='color:#300; font-size:18px;'>[&nbsp;&nbsp;"+quote+"&nbsp;&nbsp;]</span>" );
		$("#score-ct .grade").text( lastgrade );
		
		switch lastgrade
			when 'A' then root.gameAchievement 2,0
			when 'S' then root.gameAchievement 2,1
			when 'SS' then root.gameAchievement 2,2
			when 'SSS' then root.gameAchievement 2,3
		
		$("#score-ct").fadeIn()
		$("#score-ct .score").fadeIn()
		$('html, body').animate({scrollTop: $("#score-ct").offset().top}, 1500)
		
		setTimeout ->
			root.gameConfig.score = [null,null]
		,1000
		
	$("#handle").click ()->
		if $(this).text() is 'Play'
			$('html, body').animate({scrollTop: $("#game-ct > div:eq(0)").offset().top+5}, 1000)
			$(this).text('Pause')
			root.gameStart()
		else if $(this).text() is 'Pause'
			$(this).text('Continue')
			root.game.gamePause()
			root.game2.gamePause()
		else if $(this).text() is 'Continue'
			$('html, body').animate({scrollTop: $("#game-ct > div:eq(0)").offset().top+5}, 1000)
			$(this).text('Pause')
			root.game.gameResume()
			root.game2.gameResume()
	
	for i in [0...16]
		x = i%4 * 157.5
		y = Math.floor(i/4) * 157.5
		$("#score-ct .achieve .roll div:eq(#{i})").css({
			"background-position":"-#{x}px -#{y}px"
		}).mousemove( (e)->
			txt = root.gameConfig.achieve.descript[$(this).index()]
			$("#score-ct .achieve .roll p").css({
				left: e.pageX + 10
				top: e.pageY + 12
				display: 'block'
			}).text( txt )
		).mouseout( ->
			$("#score-ct .achieve .roll p").hide()
		)
	
	root.gameAchievement = ( type=0,param=null )->
		
		root.gameConfig.achieve.score[7] = 1
		if root.ach9 is 2
			root.gameConfig.achieve.score[9] = 1
		
		if type is 0
			setTimeout ->
				root.gameAchievement 1
			,1500
			return
			
		else if type is 1	
			ach = root.gameConfig.achieve.score
			c = 0
			saved = ""
			for i in [0...16]
				saved += ( ach[i] + "" )
				if ach[i] is 1
					$("#score-ct .achieve .roll div:eq(#{i})").addClass("pass")
			localStorage["game.multitask"] = saved
		
		else if type is 2
			root.gameConfig.achieve.score[param] = 1
			if param is 14
				root.gameAchievement(1)
				window.open( "../..","_blank" )
	
	
	saved = localStorage.getItem("game.multitask") || "0000000000000000"; 
	for i in [0...16]
		root.gameConfig.achieve.score[i] = parseInt( saved[i] )
	
	if root.gameConfig.achieve.score[7] isnt 1
		$("#score-ct").hide()
	else 
		root.gameAchievement 1
	
	document.getElementById("share-twt").setAttribute("src",
	"https://platform.twitter.com/widgets/tweet_button.html?count=none&url="+encodeURIComponent(document.URL)+"&text="+encodeURIComponent("How great MULTITASK are you ? Tetris & Pong Battle !!!")+"&dnt=true");
	
	$("#preloading").fadeOut('fast')
	
	return
-- palindrome
-- K2 = record/play
-- K3 = reset

local length = 30

local rec = 0
local dir = 1 -- forward direction

function init()
    setup_softcut()
    rec = 0
    length = 60
    position = 1
end

function setup_softcut()
  softcut.buffer_clear()
  -- Voice 1&2
  for i = 1, 2 do
    softcut.pre_level(i,0) -- no overdub
    audio.level_adc_cut(1)
    softcut.level_input_cut (2, i, 0) -- stereo into softcut
    softcut.level_input_cut (2, i, 0)
    audio.level_eng_cut(1)
    softcut.enable(i,1)
    softcut.buffer(i,i)
    softcut.level(i,1.0)
    -- softcut.loop(i,0) -- voice, 1 = loop
    softcut.loop_start(i,0)
    softcut.loop_end(i,100)
    softcut.position(i,1)
    softcut.fade_time(i,0.025)
    softcut.level_input_cut(2,i,1.0) -- set input rec level: input channel, voice, level
    softcut.rec_level(i,1) -- set voice record level 
    softcut.rec(i,0)
    softcut.play(i,0)
    softcut.rate(i,1)
    end
    -- softcut.voice_sync (2,1,0)
    -- Polls
    softcut.event_phase(update_positions)
    softcut.phase_quant(1,0.1)   
end

function update_positions(i,pos)
  if i == 1 then position = pos; print (position) end
    if position < 1 and dir == 0 then -- forward direction
      softcut.rate (1,1) 
      softcut.rate (2,1) 
      softcut.rec (1,1) -- head 1 record
      softcut.play (2,1) -- head 2 play
      -- softcut.pre_level(1,0)
      dir = 1
      print (">")
    end
    if position > (length+1) and dir == 1 then -- reverse direction
      softcut.rate (1,-1) 
      softcut.rate (2,-1) 
      softcut.play (1,1) -- head 1 play
      softcut.rec (2,1) -- head 2 record
      dir = 0
      print ("<")
    end
    redraw()
end

function key(n,z)
    if n == 2 and z == 1 then -- record/play
        if rec == 0 then
            softcut.poll_start_phase() -- start poll
            start_time = util.time()
            softcut.rate (1,1)
            softcut.rate (2,1)
            softcut.rec (1,1)
            -- softcut.play (1,1)
            rec = 1
            print ("recording")
        else
            length = util.time() - start_time
            rec = 0
            softcut.play (1,1)
            -- softcut.pre_level(1,1)
            print ("playing")
        end
    end
    if n == 3 and z == 1 then init(); redraw() end
end

function redraw()
       screen.clear()
       screen.move (60,10)
       screen.text_center ("palindrome")
       screen.rect (10,30,(position-1)/length*110,10)
       screen.stroke()
       screen.update()
end

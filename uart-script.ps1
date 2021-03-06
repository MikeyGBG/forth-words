function openPort {
Param ( [Object[]] $port)
$port=new-Object System.IO.Ports.SerialPort COM6,38400,None,8,one
$port.Open()
}

function close_port {
$port.close()
}

$fail = 0

function send_reply {
Param( [string]$message)
$port.Write($message)
if ( $fail -eq 0 ) { $port.Write(" ok`r`ncmd> ") }
else { $port.Write(" fail`r`ncmd> ") }
}

function s_rep {
send_reply -message "reg[0] 1"
}

function r_rep {
send_reply -message "1"
}

$reg = (0..3)
$reg[0] = 7
$reg[1] = 6
$reg[2] = 5
$reg[3] = 4
 
$arr = @()

function asc2num {
Param ( [char]$a )
return $a - 48
}

function num2asc {
Param ( [byte] $a)
return [char] ($a + 48 )
}

function read_com {
do {
   do {
	$var = $port.readChar()
        if ($var) {
             $arr += [char]$var
             $port.write([char] $var)

	}
    } 
    while ($var -ne ([char] 13))
   echo "SWITCHING WITH "
   echo $arr[0]
    switch ($arr[0]) {
	'r' { 
              $temp = asc2num -a $arr[2]
              $temp = $reg[$temp]
              $temp = num2asc -a $temp
              send_reply -message $temp }
	's' {
              $temp = asc2num -a $arr[2]
       #       $i = 4
	#      $temp2 = 0
	 #     while (($arr[4] -gt 47) -and (asc2num -a $arr[4] -lt 58)) {
	#		$temp2 = $temp2 * 10
	#		$temp2 = $temp2 + (asc2num -a $arr[4])
	#		$i = $i + 1
	 #     }
	      $temp2 = asc2num -a $arr[4]
              $reg[$temp] = $temp2
	      $string = [string]::Format("reg[{0}] {1}", $temp, $arr[4])
              send_reply -message $string
            }
        'a' { send_reply -message "Device Armed" }

        'm' { send_reply -message "Device ready for man arm" }
	'v' { send_reply -message "Version  or something" }
    }

    $arr = @()
    
}
while ($port.IsOpen)
}

PLAN

-- TEST uart processing at UI level ---
switch LCDs -> NO I2C
create uart check s ? -> gives 100% message verification -> create string s" " and give index to curPos
rewrite UIvars for no high byte
set intial values to regs
TEST FULL -> with buttons
setup uart test for reset turns BL on and off
VEROBOARD !!!!!
UNDERSTAND MTASKING ASSEMBLY
FIGURE OUT ALL MTAKSING WORDS
-> try run from task?
why can only run from operator?
CAN WORDS BE DEFINED IN TASKS?

problems with UI
-> uart premable doesnt always happen
	-> UART INIT MODIFIES TOS!!!!!!!
-> uart timeout updates Rxstart but still prints the UI
-> need to set update to 1 to trigger lcdPrintScreen after printint uart messages
-> arm man arm message never overridden <- maybe not maybe  good thing
-> Arm restore and version giving wrong nums printout
-> setInital doesnt check the return value of the reg
cleanup unused code in LCD and uart
change powershell script to send entire values
Need to handle num buffer overflow
when select pressed version stirng exits, man arm and arm never exit, restore exists after timeout
------> SPED UP BUTREAD!!!!! <- could need more ms in exec instead?
increased butTask rstack size, set TIB to 0
CHANGED MODE TO RESET TO 0 row on switch
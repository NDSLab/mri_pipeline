#!/bin/sh
# install torque prologue and epilogue scripts 
# to /bin and set correct file permissions
# scripts are based on: 
# http://docs.adaptivecomputing.com/torque/3-0-5/a.gprologueepilogue.php

cp torque_prologue.sh ~/bin
cp torque_epilogue.sh ~/bin

chmod 700 ~/bin/torque_prologue.sh
chmod 700 ~/bin/torque_epilogue.sh

echo "torque prologue and epilogue scripts copied to ~/bin"
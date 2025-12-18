declare -A root_passwords=( ['192.168.0.1']='123456' )
ansible_public_key=`cat ./src/keys/ssh-public-key`
for key in "${!root_passwords[@]}"; do
  sshpass -p ${root_passwords[$key]} ssh -o StrictHostKeyChecking=no root@$key "mkdir -p .ssh && cd .ssh && touch authorized_keys && echo $ansible_public_key >> authorized_keys"
done

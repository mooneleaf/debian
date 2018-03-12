Vagrant.configure('2') do |config|
	config.ssh.shell = 'sh'

	NAME ||= nil
	CPUS ||= 1
	MEMORY ||= 512

	[:vmware_workstation, :vmware_fusion].each do |provider|
		config.vm.provider(provider) do |vm|
			vm.whitelist_verified = true
			vm.vmx[:numvcpus] = ::CPUS
			vm.vmx[:memsize] = ::MEMORY
			unless ::NAME.nil?
				vm.vmx[:displayname] = ::NAME
			end
		end
	end

	[:parallels, :virtualbox].each do |provider|
		config.vm.provider provider do |vm|
			vm.cpus = ::CPUS
			vm.memory = ::MEMORY
			unless ::NAME.nil?
				vm.name = ::NAME
			end
		end
	end
end

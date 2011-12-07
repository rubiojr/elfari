#!/usr/bin/env ruby

require 'fog'

module AbiquoDeployer

  def self.deploying=(val)
    @deploying = val
  end

  def self.authorized?(user)
    return true if %w{rubiojr}.include?(user)
    false
  end

  def self.deploying?
    @deploying || false
  end

  def self.client=(c)
    @client = c
  end

  def self.log msg
    @client.reply "** abiquo-deployer: #{msg}"
  end

  def self.filter_output(line)
    out = nil
    if line =~ /IP Address/ or \
      line =~ /Creating VM/ or \
      line =~ /Importing VM disk/ or \
      line =~ /Error/i or \
      line =~ /VM Name/ or \
      line =~ /VM Memory/ 
      
       out = line

    end

    if out
      out = "#{out}"
    end
    out
  end

  def self.pre_process_msg(line)
    if line =~ /Setting the run_list/
      log "Bootstraping Abiquo with Chef..."
    elsif line =~ /Bootstrapping Chef/
      log "Bootstraping Opscode Chef..."
    end
  end

  def self.deploy(params={})
    if AbiquoDeployer.deploying?
      log "Dude, I'm busy deploying a VM. Wait a few minutes :S"
      return
    end
    AbiquoDeployer.deploying = true
    begin
      host = params[:host] || "blackops"
      branch = params[:branch] || "master"
      vm_memory = params[:vm_memory] || "1500"
      disk = params[:disk] || File.dirname(__FILE__) + "/../files/centos5-jeos-ip-info.qcow2"
      vm_name = params[:vm_name] || "abiquo-#{Time.now.to_i}"
      vm_password = params[:vm_password] || "centos"
      template_file = params[:template_file] || File.dirname(__FILE__) + "/bootstrap_templates/abiquo-monolithic-#{branch}.erb"

      log "deploying Abiquo MASTER..."
      IO.popen("knife kvm vm create --vm-memory #{vm_memory} --kvm-host #{host} --vm-disk #{disk} --vm-name #{vm_name} --no-host-key-verify --ssh-password #{vm_password} --template-file #{template_file}") do |p|
        p.sync = true
        p.each do |l| 
          pre_process_msg l
          out = filter_output(l)
          log out if out
        end
      end
    rescue => e
      log "Something went wrong :S"
    ensure
      AbiquoDeployer.deploying = false
    end
    if $? == 0
      log "Abiquo MASTER ready!"
    else
      log "Error deploying Abiquo MASTER!!!"
    end
  end

  def self.list_vms(params={})
    host = params[:host] || "blackops"
    uri = "qemu+tcp://#{host}/system"
    conn = Fog::Compute.new :provider => 'libvirt',
                                  :libvirt_uri => uri,
                                  :libvirt_ip_command => "virt-cat -d $server_name /tmp/ip-info 2> /dev/null |grep -v 127.0.0.1"
    conn.servers
  end

end


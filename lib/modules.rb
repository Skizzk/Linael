# -*- encoding : utf-8 -*-
module Linael
  class ModuleIRC

    include Action

    # *Intern method, don't use it*::
    # It's a methode made for generate the add_type_behaviour
    # TODO add protected (convention for *internal*)
    def add_module_irc_behavior type
      self.class.send("define_method",("add_#{type}_behavior")) do |instance,nom,ident|
        procToAdd = Proc.new {|msg| instance.send(nom,msg) if (instance.methods.grep /act_authorized\?/).empty? or act_authorized?(instance,msg)}
        (@runner.send "#{type}Act")[(instance.class::Name+ident).to_sym]= procToAdd
        @behavior ||= {}
        @behavior[type] ||= []
        @behavior[type] << ident
      end
      self.class.send("define_method",("del_#{type}_behavior")) do |instance,ident|
        (@runner.send "#{type}Act").delete((instance.class::Name+ident).to_sym)
        @behavior.delete_if {|k,v| v == ident} 
      end
    end

    # Return the current instance of a module return nil if no mod
    # Params:
    # +name+:: name of the module
    #
    #   mod("admin") #=> return admin module
    #   mod("dfgh")  #=> nil
    def mod(name)
      @runner.master.modules[name]
    end

    # TODO FIXME break backward module compatibility, it is crap
    # Name of the module. Must be equal to class name downcase
    Name=""

    # *OLD DSL method*:: Must be overided to True if you need authentication
    def self.require_auth 
      false
    end

    # *OLD DSL method*:: Must be overided if you need other modules
    def self.required_mod
      nil
    end

    # *OLD DSL method*:: Must be overided if you want to do something @load
    def load_mod

    end

    # *OLD DSL method*:: Must be overired to True if it's an authentification module
    def self.auth?
      false
    end

    # Name of module constructor.
    # Zaratan by defalut
    #
    # In new DSL should be setted in linael command.
    Constructor="Zaratan"

    # *Don't really instanciate this class*::
    def initialize(runner)
      @runner=runner
      @runner.instance_variables.grep(/@(.*)Act/) {add_module_irc_behavior $1}
    end


    # *OLD DSL method*:: use it to declare which method tu use
    # +method_hash+:: 
    # * +key+:: place to load (:cmd,:join,...)
    # * +value+:: name of the method
    def add_module(method_hash)
      method_hash.each do |k,v|
        self.methods.grep(/add_#{k.to_s}_behavior/) do |name| 
          v.each do |behav|
            self.send (name.to_sym),self,behav,behav.to_s
          end
        end
      end
    end

    # *Internal method, don't use it*
    def stopMod()
      self.behavior.each {|type,ident| ident.each { |id| self.send "del_#{type}_behavior",self,id}}
    end

    # +behavior+:: actions
    # +runner+::   container
    attr_accessor :behavior,:runner

  end

  # Containers for modules stuff
  module Modules
  end

  #Super class for Options in modules. Don't use it directly since there is a new DSL for this
  class ModulesOptions

    # +message+:: message of PrivateMessage
    # +where+:: place of PrivateMessage
    # +from_who+:: sender of PrivateMessage
    attr_reader :message,:where,:from_who

    # Initialize
    def initialize privMsg
      @message = privMsg.message
      @where = privMsg.place
      @from_who = privMsg.who
    end

    # Magic method to generate class methods for matching regex
    # +meths+:: contains an hash of:
    # * +key+:: name of the new method
    # * +value+:: regex to match
    def self.generate_to_catch meths
      meths.each do |key,regex|
        self.send("define_singleton_method","#{key.to_s}?") do |message|
          message.downcase =~ regex
        end
      end
    end

    # Super method to generate matching for Options
    # args:
    # +:name+:: name of the method 
    # +:regexp+:: regexp to match
    # +:default_meth+:: default method to call if not matchging
    # +:default+:: default value
    def self.generate_meth args
      define_method args[:name] do
        return $1 if message =~ args[:regexp]
        return self.send args[:default_meth] if args[:default_meth]
        return args[:default] unless args[:default].nil?
        ""
      end
    end

    #Define method .chan which return the first word beging with a # . if none, return current chan
    def self.generate_chan
      generate_meth :name         => "chan",
        :regexp       => /\s(#\S*)\s/,
        :default_meth => :where
    end

    #Define method .who which retrun the first word with no # nor ! nor - . If none return current user
    def self.generate_who
      generate_meth :name         => "who",
        :regexp       => /\s+([^\s\-#][^\s#]*)\s*/,
      :default_meth => :from_who
    end

    #Define method .what which return first word with no # nor !
    def self.generate_what
      generate_meth :name         => "what",
        :regexp       => /\s+([^\s#][^\s#]*)\s*/
    end

    #Define method .reason which return everything after :
    def self.generate_reason
      generate_meth :name   => "reason",
        :regexp => /\s+:([^\n\r]*)/
    end

    #Define method .type which return the first word begining with -
    def self.generate_type
      generate_meth :name   => "type",
        :regexp => /\s-(\S*)\s/
    end

    # Wrapper to add values regex
    # Params:
    # +key+:: is the name of the method (options.name)
    # +value+:: is the regex used to find the result
    def self.generate_value args
      args.each do |name,regexp|
        generate_meth :name   => name.to_s,
          :regexp => regexp
      end
    end

    # Wrapper to add values regex with a default value
    # Params:
    # +key+:: is the name of the method (options.name)
    # +value+:: is a hash with 2 keys: 
    # * +:regexp+:: the matching regex 
    # * +:default+:: the default value
    def self.generate_value_with_default args
      args.each do |name,arg|
        generate_meth :name    => name.to_s,
          :regexp  => arg[:regexp],
          :default => arg[:default]
      end
    end

    # Wrapper to add matching regex to options
    # Params:
    # +key+:: is the name of the method (options.name?)
    # +value+:: is the regex to match
    def self.generate_match args
      args.each do |name,regexp|
        generate_meth :name    => name.to_s + "?",
          :regexp  => Regexp.new("(" + regexp.to_s + ")"),
          :default => false
      end
    end

    #return EVERYTHING
    def self.generate_all
      generate_meth :name   => "all",
        :regexp => /\s(.*)/
    end

  end

end

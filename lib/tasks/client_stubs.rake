namespace :client_stubs do
  desc "Generate Client Stubs"
  task :generate => :environment do    
    Timeout.timeout(5.minutes) do
      
      path = "#{Rails.root}/tmp/client_stubs"
      Dir.mkdir(path) if !Dir.exists?(path)
      
      models = Dir["#{Rails.root}/app/models/*.rb"].map do |f|
        f.chomp('.rb').camelize.split("::").last
      end
      
      models.each do |item|
        model_name = item.to_s
        puts "generating stubs for model #{model_name}"
        
        write_file path, "#{model_name}.h", get_header_content(model_name)
        write_file path, "#{model_name}.m", get_class_content(model_name)
      end
      
      puts "finished"
    end
  end
  
  def write_file(path, name, content)
    file = File.join(path, name)
    File.open(file, "w+") do |f|
      f.write(content)
    end
  end
  
  def get_header_content(model_name)
    content = ""
    
    content = content + get_standard_header("#{model_name}.h")
    content = content + "#import \"RBManagedObject.h\"\n"
    content = content + "\n"
    content = content + "@interface #{model_name} : RBManagedObject <RBManagedObjectProtocol>\n"
    content = content + "\n"
    
    get_attributes(model_name).each do |attrib|
      content = content + "@property (nonatomic, retain) #{attrib[:data_type]} *#{attrib[:field_name]};\n"
    end
    
    content = content + "\n"
    content = content + "+ (RKObjectMapping *)writeMapping;\n"
    content = content + "\n"
    content = content + "@end\n"
    
    return content
  end
  
  def get_class_content(model_name)
    content = ""
    
    content = content + get_standard_header("#{model_name}.c")
    content = content + "#import \"#{model_name}.h\"\n"
    content = content + "\n"
    content = content + "@implementation #{model_name}\n"
    content = content + "\n"
    content = content + "@synthesize "
    
    fields = get_attributes(model_name).map {|item| item[:field_name]}
    content = content + fields.join(", ")
    
    content = content + ";\n"
    content = content + "\n"
    content = content + "+ (RKObjectMapping *)mapping {\n"
    content = content + "    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[self class]];\n"
    
    if (get_attributes(model_name).map {|item| item[:field_name]}).include?("itemId")
      content = content + "    [objectMapping addAttributeMappingsFromDictionary:@{@\"id\" : @\"itemId\"}];\n"
    end
    
    content = content + "    [objectMapping addAttributeMappingsFromArray:@["
    fields = Array.new
    get_attributes(model_name).each do |attrib|
      if attrib[:field_name] != "itemId"
        fields.push("@\"#{attrib[:field_name]}\"")
      end
    end
    content = content + fields.join(", ")
    content = content + "]];\n"
    
    content = content + "\n"
    content = content + "    return objectMapping;\n"
    content = content + "}\n"
    content = content + "\n"
    content = content + "+ (RKObjectMapping *)writeMapping {\n"
    content = content + "    RKObjectMapping *objectMapping = [RKObjectMapping requestMapping];\n"
    
    if (get_attributes(model_name).map {|item| item[:field_name]}).include?("itemId")
      content = content + "    [objectMapping addAttributeMappingsFromDictionary:@{@\"itemId\" : @\"id\"}];\n"
    end
    
    content = content + "    [objectMapping addAttributeMappingsFromArray:@["
    fields = Array.new
    get_attributes(model_name).each do |attrib|
      if attrib[:field_name] != "itemId"
        fields.push("@\"#{attrib[:field_name]}\"")
      end
    end
    content = content + fields.join(", ")
    content = content + "]];\n"
    
    content = content + "\n"
    content = content + "    return objectMapping;\n"
    content = content + "}\n"
    content = content + "\n"
    content = content + "@end\n"
    
    return content
  end
  
  def get_attributes(model_name)
    attribs = Array.new
    model_class = Object.const_get(model_name)
    ignore_fields = ["created_at", "updated_at"]
    
    model_class.columns_hash.each do |key, value|
      field_name = convert_field_name(key)
      
      if !ignore_fields.include?(field_name)
        data_type = convert_data_type(value.type)
        attribs.push({:field_name => field_name, :data_type => data_type})
      end
    end
    
    return attribs
  end
  
  def get_standard_header(file_name)
    content = ""
    
    content = content + "//\n"
    content = content + "//  #{file_name}\n"
    content = content + "//  #{Rails.application.class.parent_name.underscore}\n"
    content = content + "//\n"
    content = content + "//  Created by Radical Bear on #{Date.today.strftime('%-m/%-d/%Y')}.\n"
    content = content + "//  Copyright (c) #{Date.today.strftime('%Y')} Radical Bear LLC. All rights reserved.\n"
    content = content + "//\n"
    content = content + "\n"
    
    return content
  end
  
  def convert_field_name(ruby_name)
    if ruby_name == "id"
      return "itemId"
    else
      return ruby_name
    end
  end
  
  def convert_data_type(ruby_type)
    case ruby_type.to_s
    when "integer"
      return "NSNumber"
    when "string"
      return "NSString"
    when "datetime"
      return "NSDate"
    when "text"
      return "NSString"
    when "float"
      return "NSNumber"
    when "boolean"
      return "NSNumber"
    else
      raise "unknown data type: #{ruby_type.to_s}"
    end
  end
end
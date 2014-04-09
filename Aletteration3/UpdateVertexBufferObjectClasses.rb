#
#  UpdateVertexBufferObjectClasses.rb
#  Aletteration3
#
#  Created by David Nesbitt on 2013/10/7.
#  Copyright (c) 2013 David Nesbitt. All rights reserved.
#

def writeVertexBufferObjectFiles (typeName, structHash, modelVertexHash)
	currentDate = Time.new.strftime("%Y/%m/%d")
	currentYear = Time.new.strftime("%Y")
	
	className = 'NezVertexBufferObject'+typeName[3..typeName.length-1]

	File.open(className+'.h', 'w') do |f2|
		f2.puts('//')
		f2.puts('//  '+className+'.h')
		f2.puts('//  Aletteration3')
		f2.puts('//')
		f2.puts('//  Created by David Nesbitt on '+currentDate+'.')
		f2.puts('//  Copyright (c) '+currentYear+' David Nesbitt. All rights reserved.')
		f2.puts('//')
		f2.puts('')
		f2.puts('#import "NezVertexBufferObject.h"')
		f2.puts('')
		f2.puts('@interface '+className+' : NezVertexBufferObject')
		f2.puts('')
		f2.puts('@property (readonly, getter = getVertexList) '+typeName+' *vertexList;')
		f2.puts('')
		f2.puts('@end')
		f2.puts('')
	end

	File.open(className+'.m', 'w') do |f2|
		f2.puts('//')
		f2.puts('//  '+className+'.m')
		f2.puts('//  Aletteration3')
		f2.puts('//')
		f2.puts('//  Created by David Nesbitt on '+currentDate+'.')
		f2.puts('//  Copyright (c) '+currentYear+' David Nesbitt. All rights reserved.')
		f2.puts('//')
		f2.puts('')
		f2.puts('#import "'+className+'.h"')
		f2.puts('#import "NezGLSLProgram.h"')
		f2.puts('')
		f2.puts('@implementation '+className)
		f2.puts('')
		f2.puts('-(instancetype)initWithObjVertexArray:(NezModelVertexArray*)vertexArray {')
		f2.puts('	if ((self = [super initWithObjVertexArray:vertexArray])) {')
		f2.puts('		NSInteger vertexCount = vertexArray.vertexCount;')
		f2.puts('		'+typeName+' *vDst = self.vertexList;')
		f2.puts('		NezModelVertex *vSrc = vertexArray.vertexList;')
		f2.puts('		for (NSInteger i=0; i<vertexCount; i++) {')
		structHash.each_key {|key|
			if modelVertexHash[key] then
		f2.puts('			vDst[i].'+key+' = vSrc[i].'+key+';')
			elsif key =~ /.*Index/ || key =~ /.*ID/ then
		f2.puts('			vDst[i].'+key+' = i;')
			else
				type = structHash[key]
				if type =~ /float/ then
		f2.puts('			vDst[i].'+key+' = 0.0f;')
				elsif type =~ /GLKVector2/ then
		f2.puts('			vDst[i].'+key+' = GLKVector2Make(0.0f, 0.0f);')
				elsif type =~ /GLKVector3/ then
		f2.puts('			vDst[i].'+key+' = GLKVector3Make(0.0f, 0.0f, 0.0f);')
		elsif type =~ /GLKVector4/ then
		f2.puts('			vDst[i].'+key+' = GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f);')
		elsif type =~ /GLKQuaternion/ then
		f2.puts('			vDst[i].'+key+' = GLKQuaternionIdentity;')
				else
					puts 'unknown type:'+type
				end
			end
		}
		f2.puts('		}')
		f2.puts('	}')
		f2.puts('	return self;')
		f2.puts('}')
		f2.puts('')
		f2.puts('-(GLsizei)getSizeofVertex {')
		f2.puts('	return sizeof('+typeName+');')
		f2.puts('}')
		f2.puts('')
		f2.puts('-('+typeName+'*)getVertexList {')
		f2.puts('	return ('+typeName+'*)_vertexData.bytes;')
		f2.puts('}')
		f2.puts('')
		f2.puts('-(void)enableVertexAttributesForProgram:(NezGLSLProgram*)program {')
		structHash.each_key {|key|
			if structHash[key] == 'float' then
			f2.puts('	[self enableVertexAttributeArrayWithLocation:program.a_'+key+' size:1 stride:self.sizeofVertex offset:(void*)offsetof('+typeName+', '+key+')];')
			elsif structHash[key] == 'GLKVector2' then
			f2.puts('	[self enableVertexAttributeArrayWithLocation:program.a_'+key+' size:2 stride:self.sizeofVertex offset:(void*)offsetof('+typeName+', '+key+')];')
				elsif structHash[key] == 'GLKVector3' then
			f2.puts('	[self enableVertexAttributeArrayWithLocation:program.a_'+key+' size:3 stride:self.sizeofVertex offset:(void*)offsetof('+typeName+', '+key+')];')
			elsif structHash[key] == 'GLKVector4' then
			f2.puts('	[self enableVertexAttributeArrayWithLocation:program.a_'+key+' size:4 stride:self.sizeofVertex offset:(void*)offsetof('+typeName+', '+key+')];')
			elsif structHash[key] == 'GLKQuaternion' then
			f2.puts('	[self enableVertexAttributeArrayWithLocation:program.a_'+key+' size:4 stride:self.sizeofVertex offset:(void*)offsetof('+typeName+', '+key+')];')
			end
		}
		f2.puts('}')
		f2.puts('')
		f2.puts('@end')
	end
end

modelVertexHash = Hash.new
isStruct = false

Dir.chdir("Classes/ModelLoaders/")
File.new("NezModelVertexArray.h", "r").each { |line|
	if isStruct then
		if line =~ /\s*(\w+)\s+(\w+)\s*\;/ then
			modelVertexHash[$2] = $1
		elsif line =~ /\s*\}\s*(\w+)\s*\;/ then
			isStruct = false
		end
	elsif line =~ /\s*typedef\s+struct\s*NezModelVertex\s*\{/ then
		isStruct = true
	end
}

Dir.chdir("../../");

structHash = Hash.new
isStruct = false
foundStructFirstMember = false;
structFirstMember = ''
structName = ""
Dir.chdir("Classes/Graphics/VertexBuffer")
File.new("NezVertexTypes.h", "r").each { |line|
	if isStruct then
		if line =~ /\s*(\w+)\s+(\w+)\s*\;/ then
			structHash[$2] = $1
		elsif line =~ /\s*\}\s*(\w+)\s*\;/ then
			writeVertexBufferObjectFiles($1, structHash, modelVertexHash)
			isStruct = false
		end
	elsif line =~ /\s*typedef\s+struct\s*\{/ then
		isStruct = true
		structHash = Hash.new
	end
}

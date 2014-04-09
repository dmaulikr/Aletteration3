defineHash = Hash.new
ahash = Hash.new
uhash = Hash.new
isStruct = false
foundStructFirstMember = false;
structFirstMember = '';
structName = ""
Dir.chdir("Resources/Shaders")
Dir.glob('*.[vf]sh') do |fname|
	File.new(fname, "r").each { |line|
		if isStruct then
			if line =~ /.*[}](.*)[;].*/ then
				line = $1.strip();
				if line =~ /(.*)\[.*/ then
					if foundStructFirstMember == false then
						uhash[$1] = ['struct', $1+"[0]"];
					else
						uhash[$1] = ['struct', $1+"[0]."+structFirstMember];
					end
				else
					puts $1;
					uhash[$1] = ['struct', $1];
				end
				isStruct = false;
			elsif foundStructFirstMember == false then
				if line =~ /\s*(\w*)\s*(\w*)\s*[;].*/ then
					structFirstMember = $2;
					foundStructFirstMember = true;
				end
			end
		else
			if line =~ /struct.*/ then
				if line =~ %r{\b(\w*) \{} then
					isStruct = true;
					structFirstMember = '';
					foundStructFirstMember = false;
				end
			end
			if line =~ /attribute.*/ then
				if line =~ %r{\w* (\w*) (\w*)\;} then
					ahash[$2] = [$1, $2];
				end
			end
			if line =~ /uniform.*/ then
				if line =~ /\w* (\w*) (\w*)\;/ then
					uhash[$2] = [$1, $2];
				elsif line =~ /\w* (\w*) (\w*)\[.*\;/ then
					uhash[$2] = [$1, $2+"[0]"];
				end
			end
		end
	}
end

Dir.chdir("../../Classes/Graphics/VertexArray")
Dir.glob('NezVertexArray*.h') do |fname|
	File.open(fname, 'r').each_line do |line|
		if line =~ /#define NEZ_GLSL_.*/
			if line =~ %r{\w* (\w*) ([\w\.\-\+]*)} then
				defineHash[$1] = $2;
			end
		end 
	end
end
Dir.chdir("../../..")

currentDate = Time.new.strftime("%Y-%m-%d")
currentYear = Time.new.strftime("%Y")

File.open('Classes/OpenGL/NezGLSLCompiler.h', 'w') do |f2|
	f2.puts '//'
	f2.puts '//  NezGLSLCompiler.h'
	f2.puts '//  Aletteration3'
	f2.puts '//'
	f2.puts '//  Created by David Nesbitt on '+currentDate+'.'
	f2.puts '//  Copyright '+currentYear+' David Nesbitt. All rights reserved.'
	f2.puts '//'
	f2.puts ''
	f2.puts '#import <OpenGLES/ES3/gl.h>'
	f2.puts '#import <OpenGLES/ES3/glext.h>'
	f2.puts ''
	f2.puts '@interface NezGLSLCompiler : NSObject {'
	f2.puts '}'
	f2.puts ''
	f2.puts '@property (readonly) GLuint shader;'
	f2.puts ''
	f2.puts '+(instancetype)compilerWithVertexShader:(NSString*)vsh;'
	f2.puts '+(instancetype)compilerWithFragmentShader:(NSString*)fsh;'
	f2.puts ''
	f2.puts '-(instancetype)initWithVertexShader:(NSString*)vsh;'
	f2.puts '-(instancetype)initWithFragmentShader:(NSString*)fsh;'
	f2.puts ''
	f2.puts '@end'
end

File.open('Classes/OpenGL/NezGLSLCompiler.m', 'w') do |f2|
	f2.puts '//'
	f2.puts '//  NezGLSLCompiler.m'
	f2.puts '//  Aletteration3'
	f2.puts '//'
	f2.puts '//  Created by David Nesbitt on '+currentDate+'.'
	f2.puts '//  Copyright '+currentYear+' David Nesbitt. All rights reserved.'
	f2.puts '//'
	f2.puts ''
	f2.puts '#import "NezGLSLCompiler.h"'
	f2.puts ''
	f2.puts '#define SHADER_FOLDER @"Shaders"'
	f2.puts ''
	f2.puts '@implementation NezGLSLCompiler'
	f2.puts ''
	f2.puts '+(instancetype)compilerWithVertexShader:(NSString*)vsh {'
	f2.puts '	return [[NezGLSLCompiler alloc] initWithVertexShader:vsh];'
	f2.puts '}'
	f2.puts ''
	f2.puts '+(instancetype)compilerWithFragmentShader:(NSString*)fsh {'
	f2.puts '	return [[NezGLSLCompiler alloc] initWithFragmentShader:fsh];'
	f2.puts '}'
	f2.puts ''
	f2.puts '-(instancetype)initWithVertexShader:(NSString*)vsh {'
	f2.puts '	return [self initWithShader:vsh andType:GL_VERTEX_SHADER];'
	f2.puts '}'
	f2.puts ''
	f2.puts '-(instancetype)initWithFragmentShader:(NSString*)fsh {'
	f2.puts '	return [self initWithShader:fsh andType:GL_FRAGMENT_SHADER];'
	f2.puts '}'
	f2.puts ''
	f2.puts '-(instancetype)initWithShader:(NSString*)shader andType:(GLenum)type {'
	f2.puts '	if ((self = [super init])) {'
	f2.puts '		// Create and compile fragment shader'
	f2.puts '		NSString *file = [[NSBundle mainBundle] pathForResource:shader ofType:type==GL_VERTEX_SHADER?@"vsh":@"fsh" inDirectory:SHADER_FOLDER];'
	f2.puts '		if (![self compileShaderForType:type andFile:file]) {'
	f2.puts '			NSLog(@"Failed to compile %@ shader", type==GL_VERTEX_SHADER?@"GL_VERTEX_SHADER":@"GL_FRAGMENT_SHADER");'
	f2.puts '			return nil;'
	f2.puts '		}'
	f2.puts '	}'
	f2.puts '	return self;'
	f2.puts '}'
	f2.puts ''
	f2.puts '-(BOOL)compileShaderForType:(GLenum)type andFile:(NSString *)file {'
	f2.puts '	GLint status;'
	f2.puts '	'
	f2.puts '	const GLchar *source;'
	f2.puts '	__block NSString *programString = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];'
	f2.puts '	'
	f2.puts '	NSDictionary *defineStrings = @{'
	defineHash.each_key {|key|
	f2.puts '		@"'+key+'":@"'+defineHash[key]+'",';
	}
	f2.puts '	};'
	f2.puts '	for (NSString *key in defineStrings.keyEnumerator) {'
	f2.puts '		programString = [programString stringByReplacingOccurrencesOfString:key withString:defineStrings[key]];'
	f2.puts '	}'
	f2.puts ''
	f2.puts '	NSError *error;'
	f2.puts '	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\\\#include\\\\s+\\"(\\\\w+\\\\/)*(\\\\w+)\\\\.(\\\\w+)\\"" options:NSRegularExpressionCaseInsensitive error:&error];'
	f2.puts '	NSArray *matches = [regex matchesInString:programString options:0 range:NSMakeRange(0, [programString length])];'
	f2.puts '	[matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {'
	f2.puts '		NSRange matchRange = [match range];'
	f2.puts '		NSRange includePathRange = [match rangeAtIndex:1];'
	f2.puts '		NSRange filenameRange = [match rangeAtIndex:2];'
	f2.puts '		NSRange fileTypeRange = [match rangeAtIndex:3];'
	f2.puts ''
	f2.puts '		NSString *includePath;'
	f2.puts '		if (includePathRange.location == NSNotFound || includePathRange.length == 0) {'
	f2.puts '			includePath = @"";'
	f2.puts '		} else {'
	f2.puts '			includePath = [programString substringWithRange:includePathRange];'
	f2.puts '		}'
	f2.puts '		NSString *filename = [programString substringWithRange:filenameRange];'
	f2.puts '		NSString *fileType = [programString substringWithRange:fileTypeRange];'
	f2.puts '		NSString *fullPath = [[NSBundle mainBundle] pathForResource:filename ofType:fileType inDirectory:[NSString stringWithFormat:@"%@/%@", SHADER_FOLDER, includePath]];'
	f2.puts ''
	f2.puts '		NSStringEncoding enc;'
	f2.puts '		NSError *error;'
	f2.puts '		NSString *includeFile = [NSString stringWithContentsOfFile:fullPath usedEncoding:&enc error:&error];'
	f2.puts '		if (includeFile) {'
	f2.puts '			programString = [programString stringByReplacingCharactersInRange:matchRange withString:includeFile];'
	f2.puts '		} else {'
	f2.puts '			programString = [programString stringByReplacingCharactersInRange:matchRange withString:@""];'
	f2.puts '		}'
	f2.puts '	}];'

	f2.puts ''
	f2.puts '	source = (GLchar*)[programString UTF8String];'
	f2.puts '	if (!source) {'
	f2.puts '		NSLog(@"Failed to load vertex shader");'
	f2.puts '		return FALSE;'
	f2.puts '	}'
	f2.puts '	'
	f2.puts '	_shader = glCreateShader(type);'
	f2.puts '	glShaderSource(_shader, 1, &source, NULL);'
	f2.puts '	glCompileShader(_shader);'
	f2.puts '	'
	f2.puts '#if defined(DEBUG)'
	f2.puts '	GLint logLength;'
	f2.puts '	glGetShaderiv(_shader, GL_INFO_LOG_LENGTH, &logLength);'
	f2.puts '	if (logLength > 0) {'
	f2.puts '		GLchar *log = (GLchar *)malloc(logLength);'
	f2.puts '		glGetShaderInfoLog(_shader, logLength, &logLength, log);'
	f2.puts '		NSLog(@"Shader compile log:\n%s", log);'
	f2.puts '		free(log);'
	f2.puts '	}'
	f2.puts '#endif'
	f2.puts '	'
	f2.puts '	glGetShaderiv(_shader, GL_COMPILE_STATUS, &status);'
	f2.puts '	if (status == 0) {'
	f2.puts '		glDeleteShader(_shader);'
	f2.puts '		_shader = 0;'
	f2.puts '		return FALSE;'
	f2.puts '	}'
	f2.puts '	return TRUE;'
	f2.puts '}'
	f2.puts ''
	f2.puts '-(void)dealloc {'
	f2.puts '	if (_shader) {'
	f2.puts '		glDeleteShader(_shader);'
	f2.puts '		_shader = 0;'
	f2.puts '	}'
	f2.puts '}'
	f2.puts ''
	f2.puts '@end'
	f2.puts ''
end

File.open('Classes/OpenGL/NezGLSLProgram.h', 'w') do |f2|
	f2.puts "//"
	f2.puts "//  NezGLSLProgram.h"
	f2.puts "//  Aletteration3"
	f2.puts "//"
	f2.puts "//  Created by David Nesbitt on "+currentDate+"."
	f2.puts "//  Copyright "+currentYear+" David Nesbitt. All rights reserved."
	f2.puts "//\n\n"
	f2.puts "#import <OpenGLES/ES3/gl.h>"
	f2.puts "#import <OpenGLES/ES3/glext.h>\n\n"
	f2.puts "#define MAX_NAME_LENGTH 128\n\n"
	f2.puts "#define NEZ_GLSL_ITEM_NOT_SET -1\n\n"
	f2.puts '@class NezGLSLCompiler;'
	f2.puts ''
	f2.puts "@interface NezGLSLProgram : NSObject {"
	f2.puts "}\n\n"
	f2.puts "@property (readonly) GLuint program;"
	f2.puts "\n"
	ahash.each_key {|key|
		f2.puts "@property (readonly) GLint "+key+";"
	}
	f2.puts "\n"
	uhash.each_key {|key|
		f2.puts "@property (readonly) GLint "+key+";"
	}
	f2.puts "\n"
	f2.puts "-(instancetype)initWithShaderName:(NSString*)shaderName;\n"
	f2.puts "-(instancetype)initWithVertexShaderName:(NSString*)vsh andFragmentShaderName:(NSString*)fsh;\n"
	f2.puts "-(instancetype)initWithVertexShaderCompiler:(NezGLSLCompiler*)vertexShaderCompiler andFragmentShaderCompiler:(NezGLSLCompiler*)fragmentShaderCompiler;\n\n"
	f2.puts "@end\n"
end

File.open('Classes/OpenGL/NezGLSLProgram.m', 'w') do |f2|
f2.puts "//"
f2.puts "//  NezGLSLProgram.m"
f2.puts "//  Aletteration3"
f2.puts "//"
f2.puts "//  Created by David Nesbitt on "+currentDate+"."
f2.puts "//  Copyright "+currentYear+" David Nesbitt. All rights reserved."
f2.puts "//\n\n"
f2.puts "#import \"NezGLSLProgram.h\"\n"
f2.puts "#import \"NezGLSLCompiler.h\"\n\n"
f2.puts "@implementation NezGLSLProgram\n\n"
f2.puts "-(instancetype)initWithShaderName:(NSString*)shaderName {"
f2.puts "	return [self initWithVertexShaderName:shaderName andFragmentShaderName:shaderName];"
f2.puts "}"
f2.puts ""
f2.puts "-(instancetype)initWithVertexShaderName:(NSString*)vsh andFragmentShaderName:(NSString*)fsh {"
f2.puts "	return [self initWithVertexShaderCompiler:[NezGLSLCompiler compilerWithVertexShader:vsh] andFragmentShaderCompiler:[NezGLSLCompiler compilerWithFragmentShader:fsh]];"
f2.puts "}"
f2.puts ""
f2.puts "-(instancetype)initWithVertexShaderCompiler:(NezGLSLCompiler*)vertexShaderCompiler andFragmentShaderCompiler:(NezGLSLCompiler*)fragmentShaderCompiler {"
f2.puts "	if ((self = [super init])) {"
f2.puts "		[self initializeValues];"
f2.puts "		if (vertexShaderCompiler && fragmentShaderCompiler && vertexShaderCompiler.shader && fragmentShaderCompiler.shader) {"
f2.puts "			if (![self loadProgramWithVertexShader:vertexShaderCompiler.shader andFragmentShader:fragmentShaderCompiler.shader]) {"
f2.puts "				return nil;"
f2.puts "			}"
f2.puts "		} else {"
f2.puts "			return nil;"
f2.puts "		}"
f2.puts "	}"
f2.puts "	return self;"
f2.puts "}"
f2.puts ""
f2.puts "-(void)initializeValues {"
	ahash.each_key {|key|
		f2.puts "	_"+key+"=NEZ_GLSL_ITEM_NOT_SET;"
	}
	uhash.each_key {|key|
		f2.puts "	_"+key+"=NEZ_GLSL_ITEM_NOT_SET;"
	}
f2.puts "}\n\n"
f2.puts "-(BOOL)loadProgramWithVertexShader:(GLuint)vertexShader andFragmentShader:(GLuint)fragmentShader {"
f2.puts "	_program = glCreateProgram();"
f2.puts ''
f2.puts '	glAttachShader(_program, vertexShader);'
f2.puts '	glAttachShader(_program, fragmentShader);'
f2.puts ''
f2.puts '	GLint activeAttributeCount;'
f2.puts '	glGetProgramiv(_program, GL_ACTIVE_ATTRIBUTES, &activeAttributeCount);'
f2.puts ''
f2.puts '	GLchar itemName[MAX_NAME_LENGTH];'
f2.puts '	GLsizei nameLength;'
f2.puts '	GLint size;'
f2.puts '	GLenum type;'
f2.puts ''
f2.puts '	// Link program'
f2.puts '	if (![self linkProgram:_program]) {'
f2.puts '		NSLog(@"Failed to link program: %d", _program);'
f2.puts '		if (_program) {'
f2.puts '			glDeleteProgram(_program);'
f2.puts '			_program = 0;'
f2.puts '		}'
f2.puts '		return FALSE;'
f2.puts '	}'
f2.puts ''
f2.puts '	glGetProgramiv(_program, GL_ACTIVE_ATTRIBUTES, &activeAttributeCount);'
f2.puts '	for (GLint i=0; i<activeAttributeCount; i++) {'
f2.puts '		glGetActiveAttrib(_program, i, MAX_NAME_LENGTH, &nameLength, &size, &type, itemName);'
ahash.each_value {|value|
    f2.puts '		if (strncmp("'+value[1]+'", itemName, nameLength) == 0) { _'+value[1]+' = glGetAttribLocation(_program, itemName); }'
}
f2.puts '	}'
f2.puts ''
f2.puts '	GLint activeUniformCount;'
f2.puts '	glGetProgramiv(_program, GL_ACTIVE_UNIFORMS, &activeUniformCount);'
f2.puts '	for (GLint i=0; i<activeUniformCount; i++) {'
f2.puts '		glGetActiveUniform(_program, i, MAX_NAME_LENGTH, &nameLength, &size, &type, itemName);'
f2.puts '		// Get uniform locations'
uhash.each_key {|key|
    f2.puts '		if (strncmp("'+uhash[key][1]+'", itemName, nameLength) == 0) { _'+key+' = glGetUniformLocation(_program, itemName); }'
}
f2.puts '	}'
f2.puts '	return TRUE;'
f2.puts '}'
f2.puts ''
f2.puts '-(BOOL)linkProgram:(GLuint)prog {'
f2.puts '	GLint status;'
f2.puts ''
f2.puts '	glLinkProgram(prog);'
f2.puts '#if defined(DEBUG)'
f2.puts '	GLint logLength;'
f2.puts '	glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);'
f2.puts '	if (logLength > 0) {'
f2.puts '		GLchar *log = (GLchar *)malloc(logLength);'
f2.puts '		glGetProgramInfoLog(prog, logLength, &logLength, log);'
f2.puts '		NSLog(@"Program link log:\n%s", log);'
f2.puts '		free(log);'
f2.puts '	}'
f2.puts '#endif'
f2.puts '	glGetProgramiv(prog, GL_LINK_STATUS, &status);'
f2.puts '	if (status == 0) {'
f2.puts '		return FALSE;'
f2.puts '	}'
f2.puts '	return TRUE;'
f2.puts '}'
f2.puts ''
f2.puts '-(BOOL)validateProgram:(GLuint)prog {'
f2.puts '	GLint logLength, status;'
f2.puts ''
f2.puts '	glValidateProgram(prog);'
f2.puts '	glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);'
f2.puts '	if (logLength > 0) {'
f2.puts '		GLchar *log = (GLchar *)malloc(logLength);'
f2.puts '		glGetProgramInfoLog(prog, logLength, &logLength, log);'
f2.puts '		NSLog(@"Program validate log:\n%s", log);'
f2.puts '		free(log);'
f2.puts '	}'
f2.puts ''
f2.puts '	glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);'
f2.puts '	if (status == 0) {'
f2.puts '		return FALSE;'
f2.puts '	}'
f2.puts '	return TRUE;'
f2.puts '}'
f2.puts ''
f2.puts '-(void)dealloc {'
f2.puts '	if (_program) {'
f2.puts '		glDeleteProgram(_program);'
f2.puts '	}'
f2.puts '}'
f2.puts ''
f2.puts '@end'
f2.puts ''
end

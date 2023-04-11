/**
 * A demo of launching a JavaFX app from CommandBox.
 * Demo code from https://github.com/jfree/jfree-fxdemos
 *
 * Run with the "javafx_demo" command
 * {code}
 * javafx-demo
 * {code}
 * On first run, the command will download the JavaFX libraries and a Java 17 JDK
 */
component {
	property name='JavaService' inject;

	function run( boolean verbose=false ) {
		var javaFXSDKVersion = '17.0.6';
		var JDKVersion = javaFXSDKVersion & '+10';

		/*
		openjfx-17.0.6_linux-aarch64_bin-sdk.zip
		openjfx-17.0.6_linux-arm32_bin-sdk.zip
		openjfx-17.0.6_linux-x64_bin-sdk.zip

		openjfx-17.0.6_osx-aarch64_bin-sdk.zip
		openjfx-17.0.6_osx-x64_bin-sdk.zip

		openjfx-17.0.6_windows-x64_bin-sdk.zip
		openjfx-17.0.6_windows-x86_bin-sdk.zip
		*/
		var is32 = ()=>server.java.archModel contains 32;
		var isArm = ()=>systemSettings.getSystemSetting( 'os.arch', '' ).findNoCase( 'arm' ) || systemSettings.getSystemSetting( 'os.arch', '' ).findNoCase( 'aarch' );
		var os = '';
		var arch = '';
		if( fileSystemUtil.isWindows() ) {
			os = 'windows';
			if( is32() ) {
				arch = 'x86';
			} else {
				arch = 'x64';
			}
		} else if( fileSystemUtil.isMac() ) {
			os = 'osx';
			if( isArm() ) {
				arch = 'aarch64';
			} else {
				arch = 'x64';
			}
		} else {
			os = 'linux';
			if( isArm() ) {
				if( is32() ) {
					arch = 'arm32';
				} else {
					arch = 'aarch64';
				}
			} else {
				arch = 'x64';
			}
		}

		var getJavaFXJars = ()=>directoryList( expandPath( '/javafx-demo/JavaFX' ), true, 'array', (path)=>path.contains( '-#javaFXSDKVersion#_' ) && path.endsWith( '.jar' ) );
		var getJDK = ()=>JavaService.listJavaInstalls().filter( (name)=>name.contains( '_jdk_' ) && name.contains( JDKVersion ) );
		if( !getJavaFXJars().len() ) {
			command( 'install' )
				.params(
					ID : 'https://download2.gluonhq.com/openjfx/#javaFXSDKVersion#/openjfx-#javaFXSDKVersion#_#os#-#arch#_bin-sdk.zip',
					directory : expandPath( '/javafx-demo/JavaFX' ),
					verbose : verbose,
					save : false
				)
				.run();
		}
		if( !getJDK().len() ) {
			javaService.installJava( 'openjdk17_jdk_jdk-#JDKVersion#', verbose );
		}
		var JDKPath = javaService.getJavaInstallDirectory() & '/' & getJDK().keyArray().first() & '/bin/java';
		if( fileSystemUtil.isWindows() ) {
			JDKPath &= '.exe'
		}
		var args = [
			'"' & JDKPath & '"',
			'--module-path',
			'"' & directoryList( expandPath( '/javafx-demo/lib-modules' ), false, 'array', '*.jar' )
				.append( getJavaFXJars(), true )
				.toList( server.system.properties[ 'path.separator' ] ) & '"',
			'--add-modules',
			'org.jfree.fx.demos',
			'-classpath',
			'"' & directoryList( expandPath( '/javafx-demo/lib' ), false, 'array', '*.jar' )
				.toList( server.system.properties[ 'path.separator' ] ) & '"',
			'--module',
			'org.jfree.fx.demos/org.jfree.chart3d.fx.demo.OrsonChartsFXDemo'
		];
		if( verbose ) {
			print.yellowLine( 'Launching process...' )
				.line( args ).toConsole();
		} else {
			// Launch process in background
			if( fileSystemUtil.isWindows() ) {
				args.prepend( 'START /B ""' )
			} else {
				args.append( '&' )
			}
		}
		runCommand( '!' & args.toList( ' ' ) );
		print.greenLine( 'Launched JavaFX Demo!' );
	}

}
